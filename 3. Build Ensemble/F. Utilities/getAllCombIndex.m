function[combDex, ensSize] = getAllCombIndex( indices )

% Preallocate the size of each dimension
nDim = numel(indices);
ensSize = NaN( nDim, 1 );

% Get the number of indices in each dimension
for d = 1:nDim
    ensSize(d) = numel( indices{d} );
end

% Get the total number of combinations
nCombs = prod( ensSize );

% Get an index for each combination
combDex = (1:nCombs)';
end