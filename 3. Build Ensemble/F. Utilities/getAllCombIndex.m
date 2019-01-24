function[combDex, ensSize] = getAllCombIndex( indices )
%% Returns an index for every possible combination of dimension indices
%
% ----- Inputs -----
%
% indices: The indices in each dimension
%
% ----- Outputs -----
%
% combDex: An index for each dimension. Just a long vector.
%
% ensSize: The number of indices in each dimension.

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