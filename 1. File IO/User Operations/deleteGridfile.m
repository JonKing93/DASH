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
%       [START; STRIDE; NDELETE]. START is the index at which to begin
%       deletion. STRIDE is the interval spacing between deleted indices.
%       NDELETE is the number of indices to delete.
%
% meta: A metadata structure built for Dash. Metadata at the indices for
%       deletion are compared to this structure. If the metadata do not 
%       match, the deletion is aborted.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error check the file
m = fileCheck(file);
nDim = numel(m.dimID);

% Get the deleted dimension
if ~ismember(dim, m.dimID)
    error('Unrecognized dimension for deletion.');
else
    [~, delDim] = ismember(dim, m.dimID);
end

% Get the size of the existing data
sData = size(m.gridData);

% Error check the number of indices deleted
if ~isvector(loc) || numel(loc)~=3
    error('loc must be a 3x1 vector');
elseif loc(3)<=0 || mod(loc(3),1)~=0
    error('The third element of loc must be a positive integer.');
elseif loc(3) == sData(delDim)
    error('Cannot deleted all indices of the %s dimension', dim)
elseif ( delDim==nDim ) && ( loc(3)==sData(delDim)-1 )
    error('Cannot reduce the %s dimension to a singleton dimension.', dim);
end

% Permute the locs
dimLoc = NaN( 3, numel(m.dimID) );
dimLoc(:,delDim) = loc;

% Get the cell of indices
[ic, nAdd] = getIndexCell( m, dimLoc(3,:), dimLoc(1:2,:) );

% Get metadata for the existing data
oldMeta = m.meta;
dimID = m.dimID;

% Error check
if sum(nAdd>0) > 0
    error('Cannot delete extended indices in the %s dimension.', dimID{find(nAdd>0,1)} );
elseif exist('meta','var')
    compareMetadata(m, meta, ic);
end

% Delete the metadata and data
oldMeta.(dimID{delDim})(ic{delDim}) = [];
m.meta = oldMeta;
m.gridSize(1,delDim) = m.gridSize(1,delDim) - loc(3);

% Delete the data
m.gridData( ic{:} ) = [];

end