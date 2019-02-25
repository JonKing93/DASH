function[meta] = createEnsembleMeta( design, nState, varDex )
%% Creates metadata for an ensemble
%
% design: State vector design
%
% nState: Number of state elements
%
% varDex: State vector indices of each variable
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get a new metadata container
meta = initializeMeta( design, nState );

% For each variable
for v = 1:numel(design.var)
    var = design.var(v);
    
    % Set the value of the variable name metadata
    meta.var( varDex{v} ) = var.name;
    
    % Get the set of dimensionally subscripted state indices
    index = var.indices;
    stateDim = var.isState;
    index( var.isState & var.takeMean ) = {0};
    [combDex, siz] = getAllCombIndex( index(stateDim) );
    subState = subdim(siz, combDex);

    % Get dimensionally subscripted indices for each sequence element
    [combDex, siz] = getAllCombIndex( var.seqDex(~stateDim) );
    subSeq = subdim(siz, combDex);

    % Get some sizes
    nState = size(subState, 1);
    nSeq = size(subSeq, 1);
    nDim = numel(var.isState);

    % Preallocate a subscripted index for each element
    subDex = NaN( nState*nSeq, nDim); 

    % Replicate the state indices over each sequence element
    subDex( :, var.isState ) = repmat(subState, [nSeq,1]);

    % Replicate the sequence indices over each state element
    subSeq = repmat( subSeq(:)', [nState,1] );
    subDex(:, ~var.isState) = reshape( subSeq, [nState*nSeq, sum(~var.isState)] );
    
    % For each dimension
    for d = 1:numel(var.dimID)
        
        % If a state dimension, get metadata from grid metadata
        if var.isState(d)
            ensMeta = var.meta.(var.dimID{d});
            
            % Get the metadata in the indices.
            ensMeta = indexMetadata( ensMeta, var.indices{d} );
            
        % If an ensemble dimension, get the ensemble metadata
        else
            ensMeta = var.ensMeta{d};
            
            % !!!!!! This line is could be better. Improve it in V2
            % If no metadata was provided, just set as NaN
            if isempty(ensMeta)
                ensMeta = NaN( max(subDex(:,d)), 1);
            end
        end
        
        % If taking a mean
        if var.takeMean(d)
            
            % Place the metadata collection in a cell
            if ~iscell(ensMeta) || numel(ensMeta)>1
                ensMeta = {ensMeta};
            end
            
            % Replicate over the variable indices
            ensMeta = repmat( ensMeta, [numel(varDex{v}), 1] );
            
        % If not taking a mean
        else
            
            % Index to the appropriate metadata value for each element
            ensMeta = indexMetadata( ensMeta, subDex(:,d) );
            
            % Convert to cell if numeric
            if ~iscell(ensMeta)
                groupDim = 2:ndims(ensMeta);
                ensMeta = num2cell(ensMeta, groupDim);
            end
        end
        
        % Save to the ensemble metadata
        meta.(var.dimID{d})(varDex{v}) = ensMeta;
    end
end

end