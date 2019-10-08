function[] = append( file, newData, gridDims, dim, newMeta )
%% Appends data along a dimension in a .grid file.
%
% gridFile.append( file, gridData, gridDims, dim, newMeta )
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
%           appending dimension. It is recommended that fill values be NaN.
%
% gridDims: A list of dimension IDs indicating the order of dimensions in
%           the gridded dataset. Either a cell vector of character vectors
%           (cellstring), or a string vector.
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
[meta, dimID, gridSize] = gridFile.meta( file );

% Permute the new grid to match the old order
newData = gridFile.permuteGrid( newData, gridDims, dimID );

% Get the size of the new grid
newSize = gridFile.fullSize( newData, numel(dimID) );

% Get the index of the dimension along which to append
d = strcmp(dim, dimID);

% Check that the new data exactly matches the size of the old data except
% along the appending dimension
if ~isequal( gridSize(~d), newSize(~d) )
    bad = find( gridSize(~d) ~= newSize(~d), 1, 'first' );
    error('The length of the %s dimension in the new gridded data (%.f) does not match the length of the data in the .grid file (%.f).', ...
           dimID(bad), newSize(bad), gridSize(bad) );
end

%% Metadata

% Check that the new metadata is a valid format
newMeta = gridFile.checkMetadata( newMeta, newSize(d), 'new');

% Check that the new metadata can be appended to the old
oldMeta = ncread(file, dim);
gridFile.checkAppendMetadata( newMeta, oldMeta, newSize(d), dim );

%% Append

% Get the starting index to start writing in each dimension
sGrid = ones( size(dimID ) );
sGrid(d) = gridSize(d) + 1;

% Append the new metadata to the old
meta.(dim) = [meta.(dim); newMeta];

% Write the new values
ncwrite( file, 'gridData', newData, sGrid );

% Rewrite the appending dimensions (they seem to be deleted?)
for d = 1:numel(dimID)
    append = ncreadatt(file, dimID(d), 'append');
    if append
        ncwrite( file, dimID(d), meta.(dimID(d)) );
    end
end

end

% Setup helper function
function[gridDims, newMeta] = setup( file, gridData, gridDims, dim, newMeta )

    % Error check and return the writable matfile object
    gridFile.fileCheck( file );
    
    % Check that gridData is the same datatype as the exisitng array
    gridInfo = ncinfo(file,'gridData');
    if ~isequal( class(gridData), gridInfo.Datatype )
        error('The data type of the new gridded data (%s) is not the same as the data type in the .grid file (%s).', class(gridData), gridInfo.Datatype );
    end

    % Check the grid dimensions are allowed and non-duplicate
    gridDims = gridFile.checkGridDims(gridDims);

    % Check that the appending dimension is a dimension
    gridFile.checkDim(dim);
    
    % Check that the appending dimension is for an unlimited dimension
    append = ncreadatt( file, dim, 'append');
    if ~append
        error('The %s dimension is not enabled for appending in %s. To append along this dimension, you will need to create a new .grid file.', dim, file );
    end
    
end