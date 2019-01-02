function[ic, nAdd] = getIndexCell( m, sCurr, loc )

% Get the size of the existing data
sData = size( m.gridData );
nDim = numel(sData);   
dimID = m.dimID;

% Error check the loc. Specify STRIDE if not provided.
if isempty(loc) || size(loc,1)>2  || size(loc,2)~=nDim
    error('loc is not formatted to a correct size.');
elseif any( loc(1,:)<0)
    error('The first row of loc must be positive.');
elseif any( mod(loc(:),1)~=0 & ~isnan(loc(:)) )
    error('All values of loc must be integers or NaN.');
elseif any( loc(:) == 0 )
    error('The STRIDE component of loc cannot be zero.');
elseif size(loc,1) == 1
    loc(2,:) = 1;
end

% Create a cell of indices for each dimension
ic = repmat( {':'}, nDim, 1 );

% Keep track of the number of indices, and number of new indices in each
% dimension.
nDex = sData;
nAdd = zeros(1, nDim);

% For each dimension... 
for d = 1:nDim
    % If the loc is specified...
    if ~isnan( loc(1,d) )
        % Get the indices
        ic{d} = loc(1,d) : loc(2,d) : loc(1,d) + (sCurr(d)-1)*loc(2,d);
        
        % Ensure that indices are strictly positive
        if any( ic{d}<1 )
            error('There are negative indices for the %s dimension. Check the STRIDE values of loc.', dimID{d} );
        end
        
        % Record any new indices.
        nDex(d) = numel(ic{d});
        nAdd(d) = max(ic{d}) - sData(d);
    end
end

% Check that the new data matches the size of the indices
notnan = ~isnan(sCurr);
if ~isequal( sCurr(notnan), nDex(notnan) )
    error('The gridded data does not match the number of indices for the %s dimension.', dimID{ find(sData~=nDex,1) } );
end

end