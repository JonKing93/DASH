function[umSize, mSize, uniqDim, merge] = processSourceDims( dimOrder, iSize )
% Processes source grid dimensions
%
% iSize: Initial read size, as via inbuilt size.m


% Check the dimensions are allowed...
if ~isstrlist( dimOrder )
    error('dimOrder must be a vector that is a string, cellstring, or character row');
end
dimOrder = string(dimOrder);

% And that there are enough.
umSize = gridData.squeezeSize( iSize );
if numel(dimOrder) < numel(umSize)
    error('There are %.f named dimensions, but the source variable has more (%.f) dimensions.', numel(dimOrder), numel(umSize) );
end

% Note merged dimensions, get merged size
[uniqDim] = unique( dimOrder, 'stable' );
merge = NaN( 1, numel(dimOrder) );
mSize = iSize;
for d = 1:numel(uniqDim)
    loc = find(strcmp( uniqDim(d), dimOrder ));
    if numel(loc) > 1
        merge(loc) = d;
        mSize( loc(1) ) = prod( mSize(loc) );
        mSize( loc(2:end) ) = NaN;
    end
end

% Remove unassigned trailing singleton
mSize = mSize( ~isnan(mSize) );
mSize = gridData.squeezeSize(mSize);

% Pad with TS to match number of input dimensions
nExtraM = numel(uniqDim) - numel(mSize);
if nExtraM > 0
    mSize = [mSize, ones(1, nExtraM)];
end

nExtraUM = numel(dimOrder) - numel(umSize);
if nExtraUM > 0
    umSize = [umSize, ones(1, nExtraUM)];
end

end