function[] = gridproduct(grid1, grid2, saveName, varargin)
%% Computes the element-wise product of data stored in two .grid files.
% Saves the results to a .mat file, and creates a new .grid file to
% organize the new data.
%
% gridfile.product(grid1, grid2, saveName)
% Multiplies the data in the two gridfiles and saves to .mat and .grid
% files of the specified name. All dimensions in the gridfiles must be the
% same length, and the two gridfiles must have the same metadata elements
% for each dimension. (However, the metadata elements are not required to
% be in the same order).
%
% gridfile.product(grid1, grid2, matGridNames)
% Specify different names for the .mat and .grid files.
%
% gridfile.product(..., 'broadcast', dims)
% Indicates dimensions that should be broadcast for element-wise
% multiplication. A broadcast dimension should have a length of 1 in one
% of the gridfiles. The values from this singleton dimension will be
% applied to all elements along the dimension in the second gridfile. If a
% dimension is broadcast, the gridfiles are not required to have the same
% metadata along the dimension.
%
% gridfile.product(..., 'overwrite', overwrite)
% Specify whether to overwrite existing .mat and .grid files when saving.
% Default is to not overwrite.
%
% gridfile.product(..., 'overwrite', overwriteMatGrid)
% Specify different overwrite options for the .mat and .grid file.
%
% gridfile.product(..., 'attributes', atts)
% Specify non-dimensional attributes to include in the new .grid file's
% metadata.
%
% gridfile.product(..., "verbose", verbose)
% Indicate whether to issue broadcasting warnings. Default is to issue
% warnings.
%
% ----- Inputs -----
%
% grid1: A gridfile object
%
% grid2: A second gridfile object
%
% saveName: A string indicating the name to use for the new .mat and .grid
%    files. A string.
%
% matGridNames: A string vector or cellstring vector with two elements. The
%    first element is the name to use for the .mat file, and the second
%    element is the name to use for the .grid file.
%
% dims: A list of dimensions that should be broadcast. A string vector or
%    cellstring vector.
%
% overwrite: A scalar logical indicating whether to overwrite existing
%    files (true) or not (false -- Default)
%
% overwriteMatGrid: A logical vector with two elements. The first element
%    indicates whether to overwrite an existing .mat file, and the second
%    indicates whether to overwrite an existing .grid file.
%
% verbose: A scalar logical indicating whether to issue broadcasting
%    warnings (true -- Default) or not

% Parse the optional inputs
[broadcast, overwrite, verbose] = dash.parseInputs(varargin, ...
    ["broadcast","overwrite","verbose"], {[], [false, false], true},   3);

% Initial error check of input types
dash.assertScalarType(grid1, 'grid1', "gridfile", "gridfile");
dash.assertScalarType(grid2, 'grid2', "gridfile", "gridfile");
saveName = dash.assertStrList(saveName, 'saveName');
dash.assertVectorTypeN(overwrite, "logical", [], "overwrite");
dash.assertScalarType(verbose, "verbose", "logical", "logical");

% Get overwrite for .mat and .grid
if numel(overwrite) == 1
    overwrite = [overwrite, overwrite];
elseif numel(overwrite)>2
    error('overwrite cannot have more than two elements');
end

% Get the save name for .mat and .grid
if numel(saveName) == 1
    saveName = [saveName, saveName];
elseif numel(saveName)>2
    error('saveName cannot list more than 2 file names');
end

% Get the save files
matName = dash.setupNewFile(saveName(1), '.mat', overwrite(1));
gridName = dash.setupNewFile(saveName(2), '.grid', overwrite(2));

% Check that the gridfiles use the same dimension names
gdims = grid1.dims;
sameDims = isequal(sort(gdims), sort(grid2.dims));
assert(sameDims, 'The gridfiles do not use the same dimension names');

% Check that the broadcast dimensions are recognized. Get dimension indices
haveBroadcast = false;
if ~isempty(broadcast)
    dash.checkStrsInList(broadcast, gdims, 'dims', 'recognized dimension name');
    haveBroadcast = true;
end


% Get metadata for the gridfiles. Remove non-dimensional attributes
meta1 = grid1.meta;
meta2 = grid2.meta;

atts = gridfile.attributesName;
if isfield(meta1, atts)
    meta1 = rmfield(meta1, atts);
end
if isfield(meta2, atts)
    meta2 = rmfield(meta2, atts);
end

% Preallocate the metadata order for the second gridfile and the metadata
% structure for the final file
nDims = numel(gdims);
order = cell(1, nDims);
meta = meta1;

% Cycle through dimensions. Remove dimensions that are undefined in both files
for d = nDims:-1:1
    dim = gdims(d);
    if dash.bothNaN(meta1.(dim), meta2.(dim))
        order(d) = [];
        gdims(d) = [];
        meta = rmfield(meta, dim);
        continue;
    end
    
    % Check for broadcasting. Optionally warn user if requested but not possible
    canBroadcast = false;
    if haveBroadcast && ismember(dim, broadcast)
        sizes = [size(meta1.(dim),1), size(meta2.(dim),1)];
        if any(sizes==1)
            canBroadcast = true;
        elseif verbose
            warning('Cannot broadcast the "%s" dimension because it does not have a length of 1 in either file. (Size %.f in grid1, and size %.f in grid2)',...
                dim, sizes(1), sizes(2));
        end
    end
    
    % Process metadata for broadcast dimensions
    if canBroadcast
        if isnumeric(meta1.(dim)) && isnan(meta1.(dim))
            sizes(1) = 0;
        elseif isnumeric(meta2.(dim)) && isnan(meta2.(dim))
            sizes(2) = 0;
        end
        [~, k] = max(sizes);
        if k==2
            meta.(dim) = meta2.(dim);
        end
        
    % Otherwise, require the dimension to have the same size and metadata
    % elements in the two files
    else
        nRows = size(meta1.(dim), 1);
        assert(nRows==size(meta2.(dim),1), 'The "%s" dimension has different sizes in the two gridfiles (%.f and %.f)',...
            dim, nRows, size(meta2.(dim),1));
        
        [~, loc] = ismember(meta2.(dim), meta1.(dim));
        if any(loc==0)
            bad = find(loc==0,1);
            error('The two gridfiles do not have the same metadata elements along the "%s" dimension. (The metadata at "%s" index %.f in the second gridfile is not in the first gridfile)',...
                dim, dim, bad);
        end
        order{d} = loc;
    end
end

% Load the data and multiply
X1 = grid1.load(gdims);
X2 = grid2.load(gdims, order);
X = X1 .* X2;

% Save
save(matName, 'X', 'meta', '-v7.3');

% Build the new gridfile
grid = gridfile.new(gridName, meta, [], true);
grid.add('mat', matName, "X", gdims, meta);

end