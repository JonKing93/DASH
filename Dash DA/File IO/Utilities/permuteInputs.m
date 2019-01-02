function[gridData, dimLoc] = permuteInputs( m, gridDims, gridData, loc )

% Get the permutation ordering
permDex = getPermutation( gridDims, m.dimID, getKnownIDs );

% Permute the gridded data
gridData = permute(gridData, permDex);

% Permute the locs
dimLoc = [];
if exist('loc','var')
    nLoc = size(loc,2);
    hasloc = permDex <= nLoc;

    dimLoc = NaN( size(loc,1), numel(permDex) );
    dimLoc(:, hasloc) = loc(:, permDex(hasloc) );
end

end