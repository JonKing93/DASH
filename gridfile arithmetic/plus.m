function[] = plus(obj, grid2, filename, overwrite, attributes)
%% gridfile.plus  Add the data elements of two gridfiles
% ----------
%   obj.plus(grid2)
%   Sums the data in a second gridfile with the current gridfile. Saves the
%   sum to a .mat file and organizes into a new .grid file. The .mat and
%   .grid files are named <grid1 name>-plus-<grid2 name>
%
%   Each data dimension must either have the same length in both gridfiles,
%   or a length of 1 in one gridfile. If a dimension is the same length in
%   both gridfiles, then the gridfiles must have the same metadata along
%   the dimension. If the dimension has a length of 1 in a gridfile, then
%   that dimension is broadcast across the second gridfile. If a dimension
%   is only defined in one file, it is treated as a singleton dimension in
%   the second gridfile and broadcast.
%
%   The new gridfile will have the same dimensional metadata as the summed
%   gridfiles. Metadata for broadcast dimensions will match that of the
%   non-broadcast file. If a dimension has a length of 1 in both gridfiles,
%   the metadata will match that of gridfile calling the plus method. The
%   new file will have no metadata attributes, although see below for
%   options on specifying attributes.
%
%   obj.plus(grid2, filename)
%   Specifies the name to use for the new .mat and .grid files. Provide a
%   single name to use the same name for both files. Provide two names to
%   use different names for each file
%
%   obj.plus(grid2, filename, overwrite)
%   Specify whether to overwrite existing .mat and .grid files. If
%   overwrite is scalar, uses the same option for both files. Use two
%   elements to specify the overwrite option for each file individually.
%
%   obj.plus(grid2, filename, overwrite, attributes)
%   Options for including metadata attributes in the new .grid file.
% ----------
%   Inputs:
%       grid2 (string scalar | gridfile object): The second gridfile whose
%           data will be summed with the current gridfile.
%       filename (string scalar | string vector[2] | empty array): The name
%           to use for the new .mat and .grid files. If a single file name,
%           the name will be used for both files. If two file names, the
%           first name is used for the .mat file, and the second name is
%           used for the .grid file. If unset or an empty array, uses the
%           default name <grid1 name>-plus-<grid2 name>
%       overwrite (scalar logical | logical vector[2] | empty array):
%           Whether to overwrite existing .mat and .grid files. True allows
%           overwriting, false does not. If scalar, uses the same option
%           for both files. If two elements, uses the first option for the
%           .mat file, and the second option for the .grid file. If unset
%           or an empty array, uses false as the default value.
%       attributes (1 | 2 | scalar struct | empty array): Options for
%           setting metadata attributes in the new .grid file. If 1, copies
%           the attributes from the first gridfile to the new file. If 2,
%           copies the attributes from grid2 to the new file. If a scalar
%           struct, uses the struct directly as the attributes. If unset or
%           an empty array, the new file will have no metadata attributes.
%
%   Outputs:
%       Creates a .mat and .grid file to save and catalogue the summed data
%
%   Throws:
%
%   <a href="dash.doc('gridfile.plus')">Online Documentation</a>

% Header for errors
header = "DASH:gridfile:plus";

%% Error check / parse inputs

if dash.is.strflag(grid2)
    grid2 = gridfile(grid2);
elseif ~isa(grid2, 'gridfile')
    id = sprintf('%s:invalidGridfile', header);
    error(id, 'grid2 must either be a gridfile object, or the name of a .grid file.');
end

if ~exist('filename','var') || isempty(filename)
    filename = [obj.name,'-plus-',grid2.name];
else
    filename = dash.assert.strlist(filename, "filename", header);
    if ~dash.is.strflag(filename)
        dash.assert.vectorTypeN(filename, [], 2, "filename", header);
    end
end

if ~exist('overwrite','var') || isempty(overwrite)
    overwrite = false;
else
    dash.assert.type(overwrite, 'logical', "overwrite", header);
    if ~isscalar(overwrite)
        dash.assert.vectorTypeN(overwrite, [], 2, "overwrite", header);
    end
end

if ~exist('atts','var') || isempty(attributes)
    attributes = struct();
elseif attributes==1
    attributes = obj.metadata.attributes;
elseif attributes==2
    attributes = grid2.metadata.attributes;
elseif ~(isscalar(attributes) && isstruct(attributes))
    id = sprintf('%s:invalidAttributes', header);
    error(id, 'attributes must be one of the following: 1, 2, or a scalar struct');
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


%% Check that gridfiles can be summed

% Get gridfile dimensions, metadata, and sizes
[dims1, size1, meta1] = gridValues(obj);
[dims2, size2, meta2] = gridValues(grid2);

% Initialize metadata structure and load order for second gridfile
meta = struct();
order = repmat({[]}, numel(dims2), 1);

% Get intersecting dimensions and their lengths
[xdims, d1, d2] = intersect(dims1, dims2);
for d = 1:numel(xdims)
    dim = xdims(d);
    length1 = size1(d1(d));
    length2 = size2(d2(d));
    
    % Require matching length or length of 1
    if ~(length1==length2 || length1==1 || length2==1)
        id = sprintf('%s:dimensionLengthMismatch', header);
        error(id, ['Cannot sum %s with %s because the %s dimension has ',...
            'different lengths (%.f and %.f)'], ...
            obj.name, grid2.name, dim, length1, length2);
    end
    
    % If the same length (and not 1), require same metadata elements and
    % get the load order
    if length1==length2 && length1~=1
        [~, loc] = ismember(meta2.(dim), meta1.(dim), 'rows');
        if any(loc==0)
            id = sprintf('%s:differentMetadata', header);
            error(id, ['Cannot sum %s with %s because the files have different ',...
                'metadata along the %s dimension. (Element %.f in %2$s is not in %1$s)'],...
                obj.name, grid2.name, dim, find(loc==0,1) );
        end
        order{d2(d)} = loc;
    end
    
    % Get the metadata for the dimension
    if length1==1 && length2~=1
        meta.(dim) = meta2.(dim);
    else
        meta.(dim) = meta1.(dim);
    end
end

% Get metadata for non intersecting dimensions
udims1 = setdiff(dims1, xdims);
for d = 1:numel(udims1)
    meta.(udims1(d)) = meta1.(udims1(d));
end
udims2 = setdiff(dims2, xdims);
for d = 1:numel(udims2)
    meta.(udims2(d)) = meta2.(udims2(d));
end


%% Sum data and save

% Load data
X1 = obj.load(dims1);
X2 = grid2.load(dims2, order);

% Permute to align dimensions
allDims = [dims1, udims2];
[~, index] = ismember(dims2, allDims);
X2 = dash.permuteDimensions(X2, index, false);

% Take sum
X = X1 + X2;

% Save .mat file
saveArgs = {'meta', 'X', '-v7.3'};
if numel(fieldnames(s))==0
    saveArgs = ['attributes', saveArgs];
end
save(matName, saveArgs{:});

% Build the new .grid file
grid = gridfile.new(gridName, meta, attributes, true);
grid.add('mat', matName, 'X', alldims, meta);

end

%% Helper function
function[dims, size, meta] = gridValues(grid)
dims = grid.dims(grid.isdefined);
size = grid.size(grid.isdefined);
meta = grid.metadata;
end