function[] = appendGridfile( file, gridData, gridDims, dim, newMeta )
%% Appends data along a dimension in a .grid file.
%
% appendGridfile( file, gridData, gridDims, dim, meta )
% Appends new data to the end of a specified dimension in a .grid file.
% Adds metadata for the new indices.
%
% ----- Inputs -----
% 
% file: The name of the gridded .mat file. A string.
%
% gridData: A gridded dataset
%
% gridDims: A cell of dimension IDs indicating the order of dimensions in
%       the gridded data.
%
% dim: An ID for the dimension to be extended. A string.
%
% newMeta: Metadata for the new indices along the appending dimension.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error checking and setup
[m, gridDims] = setup( file, gridData, gridDims, dim);        

% Get the dimension ordering in the .grid file
dimID = m.dimID;

% Permute the grid to match this order
gridData = permuteGrid( gridData, gridDims, dimID );

% Get the size of the grid
gridSize = fullSize( gridData, numel(dimID) );

% Get the index of the dimension along which to append
appDim = strcmp(dim, dimID);

% Check that the new data exactly matches the size of the old data except
% along the appending dimension
if ~isequal( gridSize(~appDim), m.gridSize(~appDim) )
    sizeError( gridSize(~appDim), m.gridSize(~appDim), dimID(~appDim) );
end

% Get the new indices at which to add data along the appending dimension
oldLen = m.gridSize(appDim);
nAdd = gridSize(appDim);
newDex = oldLen+1 : oldLen + nAdd;

% Create an cell to hold the indices on which to append data for all
% dimensions
appDex = repmat( {':'}, [1, numel(dimID)] );
appDex{appDim} = newDex;

% Check that the new metadata has a row for each new index
newMeta = checkMetadataRows(newMeta, nAdd);

% Append the new metadata to the old metadata to ensure that the formats
% are compatible.
meta = appendMetadata( m.meta, newMeta, dimID(appDim) );

% Check that the new metadata contains no duplicate values
for k = oldLen+nAdd: -1: oldLen+1
    for j = k-1:-1:1
        if isequaln( meta(k,:), meta(j,:) )
            error('The new metadata duplicates values in the .grid metadata.');
        end
    end
end
        
% Append the new Data
m.gridData( appDex{:} ) = gridData;

% Update the metadata and grid size
m.meta = meta;
m.gridSize(1,appDim) = m.gridSize(1,appDim) + nAdd;
   
end 

function[m, gridDims] = setup( file, gridData, gridDims, dim )

    % Error check and return the writable matfile object
    m = fileCheck( file );
    
    % Check the gridData is numeric
    if ~isnumeric(gridData)
        error('gridData must be a numeric array.');
    end

    % Check the grid dimensions are allowed
    gridDims = checkDims(gridDims);

    % Check that the appending dimension is allowed
    checkDim(dim);
end

function[meta] = appendMetadata( meta, newMeta, field )
% Attempts to append metadata and gives an improved error message
% if appending fails.
try
    meta.(field) = [meta.(field); newMeta];
catch ME
    moreInfo = MException('DASH:appendMetadata:dimensions', ...
        ['The new metadata could not be appended to the .grid metadata. They may have different sizes or different types.', newline, ...
        'The .grid metadata can be loaded via the function "metaGridfile.m" if you wish to determine why appending failed.'] );
    ME = addCause( ME, moreInfo );
end
rethrow(ME);
end

function[] = sizeError( newSize, oldSize, dimID )
%% Throws more useful error messages when the grid sizes don't match.
d = find( newSize ~= oldSize, 1, 'first' );
error('The length of the %s dimension in the new gridded data (%.f) does not match the length of the data in the .grid file (%.f).', ...
       dimID(d), newSize(d), oldSize(d) );
end