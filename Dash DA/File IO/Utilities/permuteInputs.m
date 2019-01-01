function[gridData, dimLoc] = permuteInputs( m, gridDims, gridData, loc )

% Get the permutation ordering
permDex = getPermutation( gridDims, m.dimID, getKnownIDs );

% Permute the gridded data
gridData = permute(gridData, permDex);

% Permute the locs
dimLoc = [];
if exist('loc','var')
    dimLoc = NaN( size(loc,1), numel(permDex) );
    dimLoc(:, permDex(1:size(loc,2))) = loc;
end

end