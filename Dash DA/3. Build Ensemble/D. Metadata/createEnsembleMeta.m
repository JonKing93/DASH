function[meta] = createEnsembleMeta( design, nState, varDex )

% Get a new metadata container
meta = initializeMeta( design, nState );

% Get the name of the variable name field
[~,varName] = getKnownIDs;

% For each variable
for v = 1:numel(design.var)
    var = design.var(v);
    
    % Set the value of the variable name metadata
    meta.(varName)( varDex{v} ) = {var.name};
    
    % Get the set of dimensionally subscripted state indices
    stateDim = var.isState;
    [combDex, siz] = getAllCombIndex( var.indices(stateDim) );
    subState = subdim(siz, combDex);

    % Get dimensionally subscripted indices for each sequence element
    [combDex, siz] = getAllCombIndex( var.seqDex(~stateDim) );
    subSeq = subdim(siz, combDex);

    % Get the number of state and sequence elements
    nState = size(subState, 1);
    [nSeq, nDim] = size(subSeq);

    % Replicate the state indices over each sequence element
    subState = repmat(subState, [nSeq,1]);

    % Replicate the sequence indices over each state element
    subSeq = repmat( subSeq(:)', [nState,1] );
    subSeq = reshape( subSeq(:), [nState*nSeq, nDim]);
    
    % For each dimension
    k = 1;
    j = 1;
    for d = 1:numel(var.dimID)
        
        % If an ensemble dimension, use the sequence values in ensMeta
        if ~var.isState(d)

            % Get the ensemble metadata for each sequence element
            meta.(var.dimID{d})(varDex{v}) = var.ensMeta{d}(subSeq(:,j));
            j = j+1;
        
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
            
            % Add to the ensemble metadata
            meta.(var.dimID{d})(varDex{v}) = varMeta;
        end
    end
end

end