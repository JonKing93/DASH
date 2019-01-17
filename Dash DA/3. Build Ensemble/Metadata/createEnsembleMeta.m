function[meta] = createEnsembleMeta( design, nState, varDex )

% Get a new metadata container
meta = initializeMeta( design, nState );

% For each variable
for v = 1:numel(design.var)
    var = design.var(v);
    
    % Set the value of the variable name metadata
    meta.var( varDex{v} ) = {var.name};
    
    % Get the set of dimensionally subscripted state indices
    stateDim = var.isState;
    [combDex, siz] = getAllCombIndex( var.indices(stateDim) );
    subState = subdim(siz, combDex);    
    
    % Replicate of the set of sequence elements
    [~,nSeq] = countVarStateSeq(var);
    subState = repmat(subState, [nSeq,1]);
    
    % For each dimension
    k = 1;
    for d = 1:numel(var.dimID)
        
        % If an ensemble dimension, use the value in ensMeta
        if ~var.isState(d)
            meta.(var.dimID{d})(varDex{v}) = var.ensMeta(d);
        
        % If a state dimension...
        else
            
            % Get the variable metadata at each state element
            varMeta = var.meta.(var.dimID{d});
            varMeta = varMeta( var.indices{d} );
            varMeta = varMeta(subState(:,k));
            k = k+1;
            
            % If not a cell, convert to a cell
            if ~iscell(varMeta)
                varMeta = num2cell(varMeta);
            end
            
            % Add the ensemble metadata
            meta.(var.dimID{d})(varDex{v}) = varMeta;
        end
    end
end

end