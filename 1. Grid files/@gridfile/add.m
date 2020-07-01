function[] = add( obj, type, file, var, dims, meta )
% Adds a data source to a .grid file.
%
% obj.add( type, file, var, dims, meta )
% Adds values in a data file to the .grid file.
%
% ----- Inputs -----
%
% type: The type of data source. A string. 
%    "nc": Use when the data source is a NetCDF file.
%    "mat": Use when the data source is a .mat file.
%
% file: The name of the data source file. A string. If only the file name is
%    specified, the file must be on the active path. Use the full file name
%    (including path) to add a file off the active path.
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

% Update the gridfile object in case the file was changed.
obj.update;

% Create the dataSource object. This will error check type, file, var, and
% dims. It also has information on the size of the merged / unmerged data.
source = dataSource.new(type, file, var, dims);

% Check that all dims are recognized by the grid. Any undefined dims must
% be trailing singletons
recognized = ismember(dims, obj.dims);
if any(~recognized)
    error('Element %.f in dims (%s) is not a dimension recognized by this gridfile. See <location>.', find(~recognized,1), dims(find(~recognized,1)) );
end

ts1 = dash.lastNTS(source.mergedSize)+1;
trailingDims = source.mergedDims( ts1:end );
defined = ismember(dims, obj.dims(obj.isdefined));
trailing = ismember(dim, trailingDims);
if any(~defined & ~trailing)
    error('The %s dimension has no defined metadata in the .grid file, but is not a trailing singleton in the data source.', dims(find(~defined&~trailing,1)) );
end

% Error check the metadata. Require values for non-singleton grid
% dimensions and non-trailing dimensions in the source data.
gridfile.checkMetadataStructure(meta);
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
    [inGrid, order] = ismember(value, obj.metadata.(metaDims(d)), 'rows');
    if any(~inGrid)
        error('The %s metadata in row %.f of data source %s does not match any %s metadata in .grid file %s.', metaDims(d), source.file, find(~inGrid,1), metaDims(d), obj.file);
    elseif nRows>1 && issorted(order, 'strictdescend')
        error('The %s metadata for data source %s is in the opposite order of the %s metadata in .grid file %s.', metaDims(d), source.file, metaDims(d), obj.file );
    elseif ~issorted(order, 'strictascend')
        error('The %s metadata for data source %s is in a different order than the %s metadata in .grid file %s.', metaDims(d), source.file, metaDims(d), obj.file );
    elseif nRow>1 && ~isequal(unique(diff(order)), 1)
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
    error('The data in file %s overlaps data in file %s, which is already in .grid file %s.', source.file, obj.source(find(overlap,1)).file, obj.file);
end

% Update the fields and save to file
obj.source = [obj.source, {source}];
obj.dimLimit = cat(3, obj.dimLimit, dimLimit);
obj.save;

end