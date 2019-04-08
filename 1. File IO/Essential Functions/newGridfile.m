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
errCheck( file, gridDims, meta, gridData );

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

% Check that the metadata for each dimension has one row for each element.
for d = 1:numel(dimID)
    if size( meta.(dimID(d)), 1) ~= gridSize(d)
        error('The number of rows (%.f) in the metadata for the %s dimension does not match the length of the dimension (%.f)', ...
               size( meta.(dimID(d)),1), dimID(d), gridSize(d)  );
    end
end

% Save a v7.3 .mat file (with a .grid extension) to enalbe partial loading
% and writing
save(file, 'gridData', 'gridSize', 'dimID', 'meta', '-mat', '-v7.3');

end

function[gridDims] = errCheck( file, gridDims, meta, gridData )
        
% Check that the file is a string with a .grid extension
if ~isstrflag(file)
    error('File name must be a string.');
end
file = char(file);
if numel(file)<5 || ~strcmp( file(end-4:end), '.grid' )
    error('File must end in a .grid extension.');
end

% Check the grid dimensions
gridDims = checkDims(gridDims);

% Ensure that there is at least one gridID for each dimension of
% the gridded data
if iscolumn(gridData)
    nDim = 1;
else
    nDim = ndims(gridData);
end

if numel(gridDims) < nDim
    error('gridDims does not contain a dimension ID for each dimension of the gridded data that is not a trailing singleton.');
end

% Ensure the metadata has all required fields.
[dimID, specs] = getDimIDs;
allField = [dimID, specs];

if any( ~isfield(meta, allField) )
    d = find( ~isfield( meta, allField), 1, 'first' );
    error('Metadata does not contain a field for the %s dimension.', allField(d));
end

end