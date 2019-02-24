function[gridData, dimLoc] = permuteInputs( m, gridDims, gridData, loc )
%% Permutes gridded data to match the dimensional ordering in a gridded .mat file.
%
% [gridData, dimLoc] = permuteInputs( m, gridDims, gridData, loc )
%
% ----- Inputs -----
%
% m: A matfile object for a gridded .mat file.
%
% gridDims: A cell of dimension IDs listing the ordering of input data.
%
% gridData: A gridded data set.
%
% loc: Indexing locations.
%
% ----- Outputs -----
%
% gridData: The permuted, gridded data.
%
% dimLoc: Permuted indexing locations.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the permutation ordering
permDex = getPermutation( gridDims, m.dimID, getDimIDs );

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