function[] = fillGridfile( file, dims, loc, meta )
%% Fills indices in a gridfile with NaN.
%
% fillGridfile( file, dims, loc )
% Fills the indices in specified dimensions with NaN.
%
% fillGridfile( file, dims, loc, meta )
% Compares input metadata with metadata at the fill indices. If the
% metadata are not equivalent, aborts the fill.
%
% ----- Inputs -----
%
% file: The name of the gridded .mat file. A string.
%
% dims: A set of dimension IDs along which to fill values with NaN. A cell
%       array of strings. {nFill x 1}
%
% loc: An array specifying which indices to fill with NaN. Format is 
%       [START; STRIDE; NFILL]. Each column is one dimension. START is the
%       index at which to begin filling with NaN. STRIDE is the interval
%       spacing between fill indices. NFILL is the number of indices to
%       delete. (3 x nFill)
%
% meta: A metadata structure built for dash. Metadata at the fill
%       indices are compared to this structure. If the metadata do not 
%       match, the fill is aborted.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error check the file
m = fileCheck(file);

% Error check loc
if ~ismatrix(loc) || size(loc,1)~=3
    error('loc must be a (3 x nDim) matrix.');
elseif any( loc(3,:)<=0 | mod(loc(3,:),1)~=0 )
    error('The third row of loc must consist of positive integers.');
end

% Permute inputs to match the existing file
[~, loc] = permuteInputs(m, dims, [], loc);

% Get the cell of indices
[ic, nAdd] = getIndexCell( m, loc(3,:), loc(1:2,:) );

% Error check
if sum( nAdd>0 ) > 0
    dimID = m.dimID;
    error('The %s dimension is being extended.', dimID{find(nAdd>0,1)} );
elseif exist('meta', 'var')
    compareMetadata(m, meta, ic);
end

% Set the values to NaN
m.gridData( ic{:} ) = NaN;
    
end