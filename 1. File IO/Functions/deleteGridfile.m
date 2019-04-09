function[] = deleteGridfile( file, dim, loc, meta )
%% Deletes data from a gridded .mat file.
%
% deleteGridfile( file, dim, loc )
% Deletes data from a gridfile at the selected locations along the
% specified dimension
%
% deleteGridfile( file, dim, loc, meta )
% Checks that gridfile metadata matches the input metadata at the specified
% locations before deleting. Aborts the deletion if the metadata do not
% match.
%
% ----- Inputs -----
%
% file: The name of the gridded .mat file. A string.
%
% dim: The ID of the dimension along which to delete. A string.
%
% loc: A (3x1) vector specifying which indices to delete. Format is 
%       [START, STRIDE, NDELETE]. START is the index at which to begin
%       deletion. STRIDE is the interval spacing between deleted indices.
%       NDELETE is the number of indices to delete.
%
% meta: Metadata for the indices being deleted along the dimension.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error checking and setup
[m] = setup(file, dim, loc );

% Get the dimension ordering and grid size in the .grid file
dimID = m.dimID;
gridSize = m.gridSize;

% Get the index of the dimension along which to delete
delDim = strcmp(dim, dimID);

% Get the indices being deleted
delete = loc(1) : loc(2) : loc(1) + loc(2) * (loc(3)-1);

% Check that these indices are fully contained within the grid
if delete(end) > gridSize(delDim)
    error('Cannot delete values from index %.f along dimension %s because there are only %.f elements along this dimension.', delete(end), dimID(delDim), gridSize(delDim) );

% Don't allow a dimension to be fully deleted
elseif numel(delete) == gridSize(delDim)
    error('Cannot delete all elements from dimension %s.', dimID(delDim) );

% If the deleting dimension is the last dimension, do not let it reduce to
% a singleton dimension. (This is to preserve appending capabilities in
% v7.3 .mat files.)
elseif delDim == numel(dimID) && numel(delete) == gridSize(delDim)-1
    error('Cannot reduce dimension %s to a singleton dimension.', dimID(delDim) );
end

% Create a cell to hold the indices on which to delete data for all dimensions.
delDex = repmat( {':'}, [1, numel(dimID)] );
delDex{delDim} = delete;

% If metadata exists, check that it matches the .grid metadata at the
% indices being deleted.
if exist('meta','var')
    compareMetadata( meta, m, dimID(delDim), delete );
end
    
% Delete the data
m.gridData( delDex{:} ) = [];
    
% Update the metadata
meta = m.meta;
meta.(dimID(delDim))(delete) = [];
m.meta = meta;

% Update the grid size
m.gridSize(1,delDim) = m.gridSize(1,delDim) - numel(delete);

end

function[m] = setup(file, dim, loc )
        
% Error check the .grid file and get a matfile object
m = fileCheck(file);

% Check that dim is allowed
checkDim(dim);

% Check that loc is a 3 element vector of positive integers.
if ~isvector(loc) || length(loc)~=3
    error('loc must be a 3-element vector.');
elseif any(loc<1) || any(mod(loc,1)~=0)
    error('The elements in loc must be positive integers.');
end

end