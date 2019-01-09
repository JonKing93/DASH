function[] = newGridfile( file, gridData, gridDims, meta )
%% Creates a new gridded .mat file.
%
% newGridfile( file, gridData, gridDims, meta )
% Creates a new gridded .mat file. Checks that metadata matches data size
% in all dimensions.
%
% ----- Inputs -----
%
% file: The name of the gridded .mat file. A string.
%
% gridData: A gridded data set.
%
% gridDims: A cell of dimension IDs indicating the order of dimensions in
%       the gridded data.
%
% meta: A metadata structure for the gridded data. See the buildMetadata.m
%       function.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Check that the file is a .mat file
if isstring(file)
    file = char(file);
end
if ~strcmp( file(end-3:end), '.mat' )
    error('The file must be a .mat file.');
end

% Get the size of all non-trailing singletons
gridSize = size(gridData);
if iscolumn(gridData)
    gridSize = gridSize(1);
end
minDim = numel(gridSize);

% Ensure all dimensions that are not trailing singletons have IDs
if minDim < numel(gridDims)
    error('All dimensions that are not a trailing singleton must have IDs.');
end

% Get the known dimension IDs
knownID = getKnownIDs;

% Permute the knownIDs to match the data ordering
permDex = getPermutation( knownID, gridDims, knownID );
dimID = knownID(permDex);

% Then permute the data from smallest to largest dimension to optimize
% use with matfile indexing.
sData = fullSize(gridData, numel(dimID));
[sData, permDex] = sort( sData, 'ascend' );

gridData = permute( gridData, permDex );
dimID = dimID(permDex);

% Error check the metadata
if any( ~isfield(meta, [dimID, 'var']) )
    error('Metadata does not contain all required fields.');
elseif ~( (isstring(meta.var) && isscalar(meta.var)) || (ischar(meta.var) && isvector(meta.var)) )
    error('The ''var'' field of the metadata must be a string ID.');
end
for d = 1:numel(dimID)        
    if ~isvector( meta.(dimID{d}) )
        error('Metadata field %s must be a vector.', dimID{d});
    elseif length( meta.(dimID{d}) ) ~= sData(d)
        error('Metadata for %s does not match the size of the dimension in the gridded data.', dimID{d});
    end
end

% Get the size of the gridded data
gridSize = size(gridData);

% Save a v7.3 matfile to enable partial loading
save(file, 'gridData', 'gridSize', 'dimID', 'meta', '-v7.3');

end