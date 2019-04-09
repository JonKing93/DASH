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

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Do some error checking
errCheck( file, gridData, gridDims, meta );

% Get the set of known dimension IDs
[dimID] = getDimIDs;

% Initialize and array to hold the size of each dimension.
gridSize = ones( size(dimID) );

% Fill in the size of any non-singleton dimensions
for g = 1:numel(gridDims)
    d = strcmp( gridDims(g), dimID );
    gridSize(d) = size(gridData, g);
end

% Sort the dimensions from smallest to largest length to preserve
% appending capabilities for partially writing .mat files.
[gridSize, newOrder] = sort( gridSize );
dimID = dimID( newOrder );

% Permute the gridded data to match this order
gridData = permuteGrid( gridData, gridDims, dimID );

% Check that the metadata for each dimension has exactly one row for each element.
for d = 1:numel(dimID)
    checkMetadataRows( meta.(dimID(d)), gridSize(d), dimID(d) );
end

% Save a v7.3 .mat file (with a .grid extension) to enalbe partial loading
% and writing
save(file, 'gridData', 'gridSize', 'dimID', 'meta', '-mat', '-v7.3');

end

function[gridDims] = errCheck( file, gridData, gridDims, meta )
        
% Check for .grid extension
fileCheck(file, 'new');

% Check the data is numeric
if ~isnumeric(gridData)
    error('gridData must be a numeric array.');
end

% Check the grid dimensions
gridDims = checkDims(gridDims, gridData);

% Ensure the metadata has all required fields.
[dimID, specs] = getDimIDs;
allField = [dimID, specs];

if any( ~isfield(meta, allField) )
    d = find( ~isfield( meta, allField), 1, 'first' );
    error('Metadata does not contain a field for the %s dimension.', allField(d));
end

end