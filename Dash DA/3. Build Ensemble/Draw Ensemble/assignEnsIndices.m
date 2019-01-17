function[coupVars] = assignEnsIndices( coupVars, nEns, overlap )
%% Sets the ensemble indices that will be used in constructing an ensemble.

% Get the sampling indices for the variables
[sampleIndex, ensDimID] = drawEnsemble( coupVars, nEns, overlap );

% For each variable
for v = 1:numel(coupVars)
    
    % Get the dimensions for the sample indices
    dims = checkVarDim( coupVars(v), ensDimID );
    
    % For each dimension
    for d = 1:numel(dims)
        
        % Sample the ensemble indices
        coupVars(v).indices{dims(d)} = coupVars(v).indices{dims(d)}(sampleIndex(:,d));
    end
end

end