function[nIndex, varDex] = countVarIndices( design )

% Get some sizes
nDim = numel( design.var(1).dimID );
nVar = numel( design.var );

% Preallocate the number of indices in each dimension of each variable
nIndex = ones( nVar, nDim );

% Preallocate the variable indices
varDex = cell(nVar,1);

% Get an increment to count state vector indices.
k = 0;

% For each variable
for v = 1:nVar
    
    % For each dimension
    for d = 1:nDim
        
        % If a state dimension with no mean
        if design.var(v).isState(d) && ~design.var(v).takeMean(d)
            
            % The number of indices is the number of state indices
            nIndex(v,d) = numel( design.var(v).indices{d} );
            
        % If an ensemble dimension
        elseif ~design.var(v).isState
            
            % The number of indices is the number of sequence elements
            nIndex(v,d) = numel( design.var(v).seqDex{d} );
        end
    end
    
    % Get the state vector indices
    varDex{v} = k + (1:prod(nIndex(v,:)))';
    k = max(varDex{v});
end

end