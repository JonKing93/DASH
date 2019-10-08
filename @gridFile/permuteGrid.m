function[gridData] = permuteGrid( gridData, gridDims, dimID )
%% Permutes a gridded dataset from a particular dimensional ordering to a 
% new dimensional ordering.
%
% gridData = permuteGrid( gridData, gridDims, dimID )

% Preallocate the permutation ordering
permOrder = NaN( size(dimID) );

% For each dimension
for d = 1:numel(dimID)
    
    % Get the location of the dimension in the gridded dataset
    dimDex = find( strcmp( dimID(d), gridDims ) );
    
    % Record if not empty
    if ~isempty(dimDex)
        permOrder(d) = dimDex;
    end
end

% Replace any unfilled elements with trailing singletons
nanDim = isnan(permOrder);
permOrder(nanDim) = numel(dimID)-sum(nanDim)+1 : numel(dimID);

% Permute the gridded data
gridData = permute( gridData, permOrder );

end
