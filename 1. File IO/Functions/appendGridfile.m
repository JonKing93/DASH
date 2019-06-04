function[] = appendGridfile( file, newData, gridDims, dim, newMeta )
%% Appends data along a dimension in a .grid file.
%
% appendGridfile( file, gridData, gridDims, dim, newMeta )
% Appends new data to the end of a specified dimension in a .grid file.
% Adds metadata for the new indices.
%
% ----- Inputs -----
% 
% file: The name of the gridded .grid file in which data will be appended.
%       A string or character vector. Must have a .grid extension.
%
% newData: A gridded data set. An N-dimensional numeric array. Must match
%           the size of the pre-existing gridded data except along the
%           appending dimension.
%
% gridDims: A list of dimension IDs indicating the order of dimensions in
%           the gridded dataset. Either a cell vector of character vectors
%           (cellstring), or a string vector. All fill values should be NaN
%
% dim: The name of the dimension along which to append the new data. Either
%      a character vector or a string.
%
% newMeta: Metadata for the new indices along the appending dimension. If
%          the pre-exisiting metadata for the dimension is a vector, must
%          also be a vector. If the pre-existing metadata is a matrix, must
%          have the same nunber of columns. Must be the same data type as
%          the pre-existing metadata.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error checking and setup
[gridDims, newMeta] = setup( file, newData, gridDims, dim, newMeta);     

%% Gridded data

% Get the dimension ordering in the .grid file
[~, dimID, gridSize] = metaGridfile( file );

% Permute the new grid to match the old order
newData = permuteGrid( newData, gridDims, dimID );

% Get the size of the new grid
newSize = fullSize( newData, numel(dimID) );

% Get the index of the dimension along which to append
d = strcmp(dim, dimID);

% Check that the new data exactly matches the size of the old data except
% along the appending dimension
if ~isequal( gridSize(~d), newSize(~d) )
    bad = find( gridSize(~d) ~= newSize(~d), 1, 'first' );
    error('The length of the %s dimension in the new gridded data (%.f) does not match the length of the data in the .grid file (%.f).', ...
           dimID(bad), newSize(bad), gridSize(bad) );
end

% Check that the new metadata is acceptable
oldMeta = ncread(file, dim);
checkAppendMetadata( newMeta, oldMeta, newSize(d) );

% Get the starting index to start writing in each dimension
sGrid = ones( size(dimID ) );
sGrid(d) = gridSize(d) + 1;

sMeta = size( oldMeta );
sMeta(1) = sMeta(1) + 1;
sMeta( sMeta==1 ) = [];   % Remove the columns if a vector

% Write the new values
ncwrite( file, dim, newMeta, sMeta );
ncwrite( file, 'gridData', newData, sGrid );

end

% Setup helper function
function[gridDims, newMeta] = setup( file, gridData, gridDims, dim, newMeta )

    % Error check and return the writable matfile object
    fileCheck( file );
    
    % Check the gridData is numeric
    if ~isnumeric(gridData)
        error('gridData must be a numeric array.');
    end

    % Check the grid dimensions are allowed and non-duplicate
    gridDims = checkGridDims(gridDims);

    % Check that the appending dimension is a dimension
    checkDim(dim);
    
    % Check that the appending dimension is for an unlimited dimension
    append = ncreadatt( file, dim, 'append');
    if ~append
        error('The %s dimension is not enabled for appending in %s. To append along this dimension, you will need to create a new .grid file.', dim, file );
    end
    
    % Check that the new metadata is allowed
    newMeta = checkMetadata( newMeta, length(newMeta), 'new');
end