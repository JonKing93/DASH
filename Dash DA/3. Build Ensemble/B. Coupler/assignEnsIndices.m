function[coupVars] = assignEnsIndices( coupVars, sampDex, ensID )
%% Sets the ensemble indices that will be used in constructing an ensemble.

% For each variable
for v = 1:numel(coupVars)
    
    % Get the dimensions for the sample indices
    dims = checkVarDim( coupVars(v), ensID );
    
    % For each dimension
    for d = 1:numel(dims)
        
        % Sample the ensemble indices
        coupVars(v).indices{dims(d)} = coupVars(v).indices{dims(d)}(sampDex(:,d));
    end
end

end