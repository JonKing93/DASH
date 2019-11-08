function[umSize, mSize, uniqDim, merge, mergeSet] = processSourceDims( dimOrder, iSize )
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
mSize = gridData.fullSize( iSize, numel(dimOrder) );
for d = 1:numel(uniqDim)
    loc = find(strcmp( uniqDim(d), dimOrder ));
    if numel(loc) > 1
        merge(loc) = d;
        mSize( loc(1) ) = prod( mSize(loc) );
        mSize( loc(2:end) ) = NaN;
    end
end

% Restrict to merged dimensions
mergeSet = merge( ~isnan(mSize) );
mSize = mSize( ~isnan(mSize) );

% Pad unmerged size with trailing singleton to match number of input dims
nExtra = numel(dimOrder) - numel(umSize);
if nExtra > 0
    umSize = [umSize, ones(1,nExtra)];
end

end