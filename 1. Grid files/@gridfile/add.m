function[] = add( obj, type, file, var, dims, meta, varargin )
% Adds a data source to a .grid file.
%
% obj.add( type, file, var, dims, meta )
% Add a data source. Notes the type of data source (NetCDF vs .mat), the
% name of the file, the name of the data variable in the file, the order of
% the dimensions for the variable, and the metadata associated with each
% dimension.
%
% obj.add( ..., 'fill', fill )
% Specifies a fill value for the data source. When data is loaded from the
% data source, elements with a value equal to fill are converted to NaN. If
% unset, does not use a fill value.
%
% obj.add( ..., 'validRange', range )
% Specifies the valid range for values in a data source. When data is
% loaded from the data source, elements with a value outside of the range
% are converted to NaN. If unset, defaults to [-Inf Inf].
%
% obj.add( ..., 'convert', convert )
% When data is loaded from the data source, applies a transformation:
% Y = aX + b  to all values. See the details of the "convert" input. If unset,
% does not apply a linear transformation to loaded data.
%
% obj.add( ..., 'absolutePath', absolute )
% Specify whether to save the data source file name as an absolute path or
% as a path relative to the .grid file. If unspecified, uses a relative
% path when possible.
%
% ----- Inputs -----
%
% type: The type of data source. A string. 
%    "nc": Use when the data source is a NetCDF file.
%    "mat": Use when the data source is a .mat file.
%
% file: The name of the data source file. A string. If only the file name 
%    or part of the file path is specified, the file must be on the active
%    path. Use the full file path to add a file off the active path. All
%    file names must include the file extension.
%
% var: The name of the variable in the source file.
%
% dims: The order of the dimensions of the variable in the source file. A
%    string or cellstring vector.
%
% meta: The dimensional metadata structure for the data in the source file.
%    See gridfile.defineMetadata. Must include metadata for all
%    non-singleton dimensions in the .grid file (see <include>) and for all
%    non-trailing dimensions in the source file. The number of rows in each
%    metadata field must match the length of the dimension in the source
%    file. Each metadata field must exactly match a contiguous sequence of
%    metadata in the .grid file.
%
% fill: A fill value. Must be a scalar. When data is loaded from the file, 
%    values matching fill are converted to NaN. 
%
% range: A valid range. A two element vector. The first element is the
%    lower bound of the valid range. The second elements is the upper bound
%    of the valid range. When data is loaded from the file, values outside
%    of the range are converted to NaN.
%
% convert: Applies a linear transformation of form: Y = aX + b
%    to loaded data. A two element vector. The first element specifies the
%    multiplicative constant (a). The second element specifieds the
%    additive constant (b).
%
% absolute: A scalar logical indicating whether to save data source file
%    names as an absolute path (true), or as a path relative to the .grid
%    file (false). Default is false.

% Update the gridfile object in case the file was changed.
obj.update;

% Parse and error check the optional inputs (fill, range, convert)
[fill, range, convert, absolute] = dash.parseInputs( varargin, {'fill','validRange','convert','absolutePath'}, ...
                                      {NaN, [-Inf, Inf], [1 0], false}, 5 );
if ~isnumeric(fill) || ~isscalar(fill)
    error('fill must be a numeric scalar.');
elseif ~isvector(range) || numel(range)~=2 || ~isnumeric(range)
    error('range must be a numeric vector with two elements.');
elseif ~isreal(range) || any(isnan(range))
    error('range may not contain contain complex values or NaN.');
elseif range(1) > range(2)
    error('The first element of range cannot be larger than the second element.');
elseif ~isvector(range) || ~isnumeric(convert) || numel(convert)~=2
    error('convert must be a numeric vector with two elements.');
elseif ~isreal(convert) || any(isnan(convert)) || any(isinf(convert))
    error('convert may not contain complex values, NaN, or Inf.');
elseif ~isscalar(absolute) || ~islogical(absolute)
    error('absolute must be a scalar logical.');
end
    
% Create the dataSource object. This will error check type, file, var, and
% dims. It also has information on the size of the merged / unmerged data.
source = dataSource.new(type, file, var, dims, fill, range, convert);

% Check that all dims are recognized by the grid. Any dims with undefined
% .grid metadata must be trailing dimensions in the data source.
obj.checkAllowedDims(dims);

ts1 = max( [2, find(source.mergedSize~=1,1,'last')+1] );
trailingDims = source.mergedDims( ts1:end );
defined = ismember(dims, obj.dims(obj.isdefined));
trailing = ismember(dims, trailingDims);
if any(~defined & ~trailing)
    error('The %s dimension has no defined metadata in the .grid file, but is not a trailing singleton dimension in the data source.', dims(find(~defined&~trailing,1)) );
end

% Error check the metadata. Require values for non-singleton grid
% dimensions and non-trailing dimensions in the source data.
gridfile.checkMetadataStructure(meta, obj.dims(obj.isdefined), "dimensions with defined metadata in the .grid file");
metaFields = string(fields(meta));
gridRequired = obj.dims( obj.size~=1 );
sourceRequired = source.mergedDims(1:ts1-1);
requiredDims = unique([gridRequired, sourceRequired]);

missing = ~ismember(requiredDims, metaFields);
if any(missing)
    error('meta must include metadata for the %s dimension.', requiredDims(find(missing,1)) );
end

% Preallocate the limits of the source dimensions in the .grid file grid
nDim = numel(obj.dims);
dimLimit = ones(nDim, 2);

% Cycle through the metadata fields that are grid dimensions. Check the
% values have as many rows as the dimension size in the source data. 
metaDims = metaFields(ismember(metaFields, obj.dims));
for d = 1:numel(metaDims)
    value = meta.(metaDims(d));
    nRows = size(value,1);
    s = ismember(source.mergedDims, metaDims(d));
    if nRows ~= source.mergedSize(s)
        error('The number of rows in the %s metadata (%.f) does not match the length of the %s dimension in the data source (%.f).', metaDims(d), size(value,1), metaDims(d), source.mergedSize(s) );
    end
    
    % The source metadata must exactly match a sequence of .grid metadata
    [inGrid, order] = ismember(value, obj.meta.(metaDims(d)), 'rows');
    if any(~inGrid)
        error('The %s metadata in row %.f of data source %s does not match any %s metadata in .grid file %s.', metaDims(d), find(~inGrid,1), source.file, metaDims(d), obj.file);
    elseif nRows>1 && issorted(order, 'strictdescend')
        error('The %s metadata for data source %s is in the opposite order of the %s metadata in .grid file %s.', metaDims(d), source.file, metaDims(d), obj.file );
    elseif ~issorted(order, 'strictascend')
        error('The %s metadata for data source %s is in a different order than the %s metadata in .grid file %s.', metaDims(d), source.file, metaDims(d), obj.file );
    elseif nRows>1 && ~isequal(unique(diff(order)), 1)
        error('The %s metadata for data source %s skips elements that are in the %s metadata for .grid file %s.', metaDims(d), source.file, metaDims(d), obj.file );
    end
    
    % Record the limits of the source data dimensions in the .grid file
    g = ismember(obj.dims, metaDims(d));
    dimLimit(g,:) = [min(order), max(order)];
end
    
% Check that the source data does not overlap data in another source in the
% .grid file
lower = all(dimLimit<obj.dimLimit(:,1,:), 2);
higher = all(dimLimit>obj.dimLimit(:,2,:), 2);
overlap = all(~(lower|higher), 1);
if any(overlap)
    error('The data in new source file %s overlaps data in file %s, which is already in .grid file %s.', source.file, obj.source.file(find(overlap,1),:), obj.file);
end

% Convert the dataSource object into a structure of primitives and
% implement the desired filepath style
source = gridfile.convertSourceToPrimitives(source);
source.file = obj.sourceFilepath(source.file, absolute);

% Preallocate the length of each of the primitive fields
sourceFields = fields(obj.source);
nField = numel(sourceFields);
fieldLength = NaN(1,nField);

% Get the length of each field in the new source. Update the maximum length
% of the primitive arrays in the .grid file
for f = 1:numel(sourceFields)
    name = sourceFields{f};
    fieldLength(f) = length( source.(name) );
    obj.maxLength(f) = max( obj.maxLength(f), fieldLength(f) );
    
    % Pad the primitives for the new source or for the .grid file as necessary
    if obj.maxLength(f) > fieldLength(f)
        source.(name) = gridfile.padPrimitives( source.(name), obj.maxLength(f) );
    elseif ~isempty(obj.source.(name))
        obj.source.(name) = gridfile.padPrimitives( obj.source.(name), fieldLength(f) );
    end
    
    % Add the new primitives to the source structure.
    obj.source.(name) = cat(1, obj.source.(name), source.(name));
end
    
% Update the other source variables and save
obj.fieldLength = cat(1, obj.fieldLength, fieldLength);
obj.dimLimit = cat(3, obj.dimLimit, dimLimit);
obj.save;

end