%% This fills indices with NaN
function[] = fillGridfile( file, dims, loc, meta )

% Error check the file
m = fileCheck(file);
nDim = numel(m.dimID);

% Error check loc
if ~ismatrix(loc) || size(loc,1)~=3
    error('loc must be a (3 x nDim) matrix.');
elseif any( loc(3,:)<=0 || mod(loc(3,:),1)~=0 )
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