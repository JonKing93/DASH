function[] = arithmetic(obj, operation, grid2, filename, overwrite, attributes, type)
%% gridfile.arithmetic  Arithmetic operations across two gridfiles
% ----------
%   obj.arithmetic(operation, grid2, filename, overwrite, atts, type)
%   Implement an arithmetic operation on the data in two .grid files. Saves
%   the result of the operation to a .mat file and catalogue the result in
%   a new .grid file.
% ----------

%% Operation specific details

% Header for errors
header = sprintf('DASH:gridfile:%s', operation);

% Arithmetic function and error strings
if strcmpi(operation, 'plus')
    math = @plus;
    strs = ["sum", "with"];
elseif strcmpi(operation, 'minus')
    math = @minus;
    strs = ["subrtract","from"];
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
elseif ~isa(grid2, 'gridfile')
    id = sprintf('%s:invalidGridfile', header);
    error(id, 'grid2 must either be a gridfile object, or the name of a .grid file.');
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
if ~exist('attributes','var') || isempty(attributes)
    attributes = struct();
elseif attributes==1
    attributes = obj.metadata.attributes;
elseif attributes==2
    attributes = grid2.metadata.attributes;
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
matName = dash.file.setupNew(filename(1), ".mat", overwrite(1));
gridName = dash.file.setupNew(filename(2), ".grid", overwrite(2));


%% Check that gridfiles can be summed. Get load order and metadata

% Get gridfile dimensions, metadata, and sizes
[dims1, size1, meta1] = gridValues(obj);
[dims2, size2, meta2] = gridValues(grid2);

% Initialize metadata structure and load order for second gridfile
meta = struct();
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
            [meta.(dim), order1{d1(d)}, order2{d2(d)}] = ...
            intersect(meta1.(dim), meta2.(dim), 'rows', 'stable');
            if isempty(meta.(dim))
                noOverlapError(strs, obj.name, grid2.name, dim, header);
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
            meta.(dim) = meta1.(dim);
        end

    % BROADCAST DIMENSIONS
    elseif length2==1
        meta.(dim) = meta1.(dim);
    else
        meta.(dim) = meta2.(dim);
    end
end

% NON-INTERSECTING
udims1 = setdiff(dims1, xdims);
for d = 1:numel(udims1)
    meta.(udims1(d)) = meta1.(udims1(d));
end
udims2 = setdiff(dims2, xdims);
for d = 1:numel(udims2)
    meta.(udims2(d)) = meta2.(udims2(d));
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
atts = {};
if numel(fieldnames(attributes))~=0
    atts = {'attributes'};
end
save(matName, 'meta', atts{:}, 'X', '-v7.3');

% Build new .grid file
grid = gridfile.new(gridName, meta, attributes, true);
grid.add("mat", matName, "X", alldims, meta);

end

%% Helper function
function[dims, size, meta] = gridValues(grid)
dims = grid.dims(grid.isdefined);
size = grid.size(grid.isdefined);
meta = grid.metadata;
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
function[] = noOverlapError(strs, name1, name2, dim, header)
id = sprintf('%s:noOverlappingMetadata', header);
error(id, ['Cannot %s %s %s %s because there is no overlapping metadata along ',...
    'the %s dimension'], strs(1), name1, strs(2), name2, dim);
end