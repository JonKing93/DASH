function[] = arithmetic(obj, operation, grid2, filename, overwrite, attributes, type)
%% gridfile.arithmetic  Arithmetic operations across two gridfiles
% ----------
%   obj.arithmetic(operation, grid2, filename, overwrite, atts, type)
%   Implement an arithmetic operation on the data in two .grid files. Saves
%   the result of the operation to a .mat file and catalogues the result in
%   a new .grid file.
% ----------
%   Inputs:
%       operation ('plus' | 'minus' | 'times' | 'divide'): The arithmetic
%           operation to apply to the two gridfiles
%       grid2 (string scalar | gridfile object): The second gridfile to use in
%           the arithmetic operation.
%       filename (string scalar | string vector[2]): The name to use for the
%           new .mat and .grid files. If a single file name, the name will be
%           used for both files. If two file names, the first name is used for
%           the .mat file, and the second name is used for the .grid file.
%       overwrite (scalar logical | logical vector[2]): Whether to overwrite
%           existing .mat and .grid files. True allows overwriting, false does
%           not. If scalar, uses the same option for both files. If two
%           elements, uses the first option for the .mat file, and the second
%           option for the .grid file. Default is false.
%       attributes (1 | 2 | scalar struct | empty array): Options for
%           setting metadata attributes in the new .grid file. If 1, copies
%           the attributes from the first gridfile to the new file. If 2,
%           copies the attributes from grid2 to the new file. If a scalar
%           struct, uses the struct directly as the attributes. If unset or
%           an empty array, the new file will have no metadata attributes.
%       type (1 | 2 | 3): Options for matching gridfile metadata and sizes.
%           [1 (default)]: requires data dimensions to have compatible sizes
%           AND have the same metadata along each non-singleton dimension.
%           Does arithmetic on all data elements.
%           [2]: Searches for data elements with matching elements in
%           non-singleton dimensions. Only does arithmetic at these elements.
%           Does not require data dimensions to have compatible sizes.
%           [3]: Does not compare dimensional metadata. Loads all data elements
%           from both files and applies arithmetic directly. Requires data
%           dimensions to have compatible sizes.
%
%   Outputs:
%       Creates a .mat and .grid file with the specified names
%
%   Throws:
%       DASH:gridfile:<operation>:invalidGridfile  when grid2 is not a
%           valid gridfile
%       DASH:gridfile:<operation>:invalidAttributes  when attributes is not
%           a recognized option
%       DASH:gridfile:<operation>:invalidType  when type is not a
%           recognized option
%       DASH:gridfile:<operation>:dimensionLengthMismatch  when type is 1
%           or 3 and the data dimensions do not have compatible sizes
%       DASH:gridfile:<operation>:differentMetadata  when type is 1 and
%           there is different metadata along a non-singleton dimension
%       DASH:gridfile:<operation>:noMatchingMetadata  when type is 2 and
%           there is no matching metadata along a non-singleton dimension
%
% <a href="matlab:dash.doc('gridfile.arithmetic')">Online Documentation</a>

%% Operation specific details

% Header for errors
header = sprintf('DASH:gridfile:%s', operation);

% Arithmetic function and error strings
if strcmpi(operation, 'plus')
    math = @plus;
    strs = ["sum", "with"];
elseif strcmpi(operation, 'minus')
    math = @minus;
    strs = ["subtract","from"];
elseif strcmpi(operation, 'times')
    math = @times;
    strs = ["multiply","by"];
elseif strcmpi(operation, 'divide')
    math = @rdivide;
    strs = ["divide","by"];
end

%% Error check / parse inputs

% Second gridfile
if dash.is.strflag(grid2)
    grid2 = gridfile(grid2);
elseif ~isa(grid2, 'gridfile') || ~isscalar(grid2)
    id = sprintf('%s:invalidGridfile', header);
    error(id, 'grid2 must either be a scalar gridfile object, or the name of a .grid file.');
end

% Names of new save files
filename = dash.assert.strlist(filename, "filename", header);
if ~dash.is.strflag(filename)
    dash.assert.vectorTypeN(filename, [], 2, "filename", header);
end

% File overwrite
if ~exist('overwrite','var') || isempty(overwrite)
    overwrite = false;
else
    dash.assert.type(overwrite, 'logical', "overwrite", [], header);
    if ~isscalar(overwrite)
        dash.assert.vectorTypeN(overwrite, [], 2, "overwrite", header);
    end
end

% Metadata attributes
[~, atts] = gridMetadata.dimensions;
if ~exist('attributes','var') || isempty(attributes)
    attributes = struct();
elseif attributes==1
    attributes = obj.meta.(atts);
elseif attributes==2
    attributes = grid2.meta.(atts);
elseif ~(isscalar(attributes) && isstruct(attributes))
    id = sprintf('%s:invalidAttributes', header);
    error(id, 'attributes must be one of the following: 1, 2, or a scalar struct');
end

% Metadata matching / size matching options
if ~exist('type','var') || isempty(type)
    type = 1;
else
    dash.assert.scalarType(type, 'numeric', "type", header);
    if ~ismember(type, 1:3)
        id = sprintf('%s:invalidType', header);
        error(id, 'type must be either 1, 2, or 3');
    end
end


%% Setup for new .mat and .grid files

% Propagate filename and overwrite
if isscalar(filename)
    filename = [filename, filename];
end
if isscalar(overwrite)
    overwrite = [overwrite, overwrite];
end

% Setup for new files
matName = dash.file.new(filename(1), ".mat", overwrite(1));
gridName = dash.file.new(filename(2), ".grid", overwrite(2));


%% Check that gridfiles can be operated on. Get load order and metadata

% Get gridfile dimensions, metadata, and sizes
[dims1, size1, meta1] = gridValues(obj);
[dims2, size2, meta2] = gridValues(grid2);

% Initialize metadata structure and load order for second gridfile
meta = gridMetadata;
order1 = repmat({[]}, numel(dims1), 1);
order2 = repmat({[]}, numel(dims2), 1);

% INTERSECTING DIMENSIONS
% Iterate over intersecting dimensions, get lengths
[xdims, d1, d2] = intersect(dims1, dims2);
for d = 1:numel(xdims)
    dim = xdims(d);
    length1 = size1(d1(d));
    length2 = size2(d2(d));
    
    % Require compatible sizes for types 1 and 3
    if ismember(type, [1 3]) && length1~=length2 && length1~=1 && length2~=1
        dimensionLengthError(strs, obj.name, grid2.name, dim, length1, length2, header);
    end
    
    % NON-BROADCAST DIMENSIONS
    % Type 1: Require same metadata, order grid2 to match grid1
    % Type 2: Get metadata intersection, order both grids to intersect
    % Type 3: Use grid1 metadata
    if length1==length2 && length1~=1
        if type==2
            [dimMetadata, order1{d1(d)}, order2{d2(d)}] = ...
            intersect(meta1.(dim), meta2.(dim), 'rows', 'stable');
            if isempty(dimMetadata)
                noMatchingMetadataError(strs, obj.name, grid2.name, dim, header);
            end
        else
            if type==1
                [~, loc] = ismember(meta1.(dim), meta2.(dim), 'rows');
                if any(loc==0)
                    bad = find(loc==0,1);
                    differentMetadataError(strs, obj.name, grid2.name, dim, bad, header);
                end
                order2{d2(d)} = loc;
            end
            dimMetadata = meta1.(dim);
        end

    % BROADCAST DIMENSIONS
    elseif length2==1
        dimMetadata = meta1.(dim);
    else
        dimMetadata = meta2.(dim);
    end
    
    % Update metadata
    meta = meta.edit(dim, dimMetadata);
end

% NON-INTERSECTING
udims1 = setdiff(dims1, xdims);
for d = 1:numel(udims1)
    dim = udims1(d);
    meta = meta.edit(dim, meta1.(dim));
end
udims2 = setdiff(dims2, xdims);
for d = 1:numel(udims2)
    dim = udims2(d);
    meta = meta.edit(dim, meta2.(dim));
end


%% Arithmetic, Save, Create .grid file

% Load data
X1 = obj.load(dims1);
X2 = grid2.load(dims2, order);

% Permute to align dimensions
allDims = [dims1, udims2];
[~, index] = ismember(dims2, allDims);
X2 = dash.permuteDimensions(X2, index, false);

% Do arithmetic operation
X = math(X1, X2);

% Save .mat file
meta = meta.edit(atts, attributes);
save(matName, 'meta', 'X', '-v7.3');

% Build new .grid file
grid = gridfile.new(gridName, meta, true);
grid.add("mat", matName, "X", alldims, meta);

end

%% Helper function
function[dims, size, meta] = gridValues(grid)
dims = grid.dims;
size = grid.size;
meta = grid.meta;
end

%% Long error messages
function[] = dimensionLengthError(strs, name1, name2, dim, length1, length2, header)
id = sprintf('%s:dimensionLengthMismatch', header);
error(id, ['Cannot %s %s %s %s because the %s dimension has different ',...
    'lengths (%.f and %.f)'], ...
    strs(1), name1, strs(2), name2, dim, length1, length2);
end
function[] = differentMetadataError(strs, name1, name2, dim, index, header)
id = sprintf('%s:differentMetadata', header);
error(id, ['Cannot %s %s %s %s because the files have different metadata along ',...
    'the %s dimension. (Element %.f in %2$s is not in %1$s)'],...
    strs(1), name1, strs(2), name2, dim, index);
end
function[] = noMatchingMetadataError(strs, name1, name2, dim, header)
id = sprintf('%s:noMatchingMetadata', header);
error(id, ['Cannot %s %s %s %s because there is no matching metadata along ',...
    'the %s dimension'], strs(1), name1, strs(2), name2, dim);
end