function[coupVars] = assignEnsIndices( coupVars, sampDex, ensID )
%% Sets the ensemble indices that will be used in constructing an ensemble.
%
% coupVars: A set of coupled varDesigns
%
% sampDex: Sampling indices from the ensemble draws
%
% ensID: Name of ensemble dimensions
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% For each variable
for v = 1:numel(coupVars)
    
    % Get the dimensions for the sample indices
    dims = checkVarDim( coupVars(v), ensID );
    
    % For each dimension
    for d = 1:numel(dims)
        
        % Sample the ensemble indices
        coupVars(v).indices{dims(d)} = sampDex(:,d);
    end
end

end