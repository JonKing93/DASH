function[meta] = ensembleMetadata( design )
%% Generates the ensemble metadata for an ensemble.

% Get the state indices associated with each variable
[varDex, varDim] = getVarIndices( design.var );

% Get the total number of state elements
nState = sum( prod(varDim,2) , 1);

% Initialize an empty metadata container with a row for each state element.
meta = initializeMeta( design, nState );

% For each variable
for v = 1:numel(design.var)
    var = design.var(v);
    
    % Set the value of the variable name metadata
    meta.var( varDex{v} ) = var.name;
    
    % Get the number of elements for the variable
    nEls = prod( varDim(v,:) );
    
    % Get the N-dimensional subscript indices
    subDex = subdim( varDim(v,:) , (1:nEls)' );
    
    % For each dimension
    for d = 1:numel(var.dimID)
        
        % If a state dimension, get metadata from grid metadata
        if var.isState(d)
            ensMeta = var.meta.(var.dimID(d));
            
            % Use the metadata at the state indices, preserving any
            % higher order dimensionality inherent in the metadata.
            ensMeta = indexMetadata( ensMeta, var.indices{d} );
            
        % If an ensemble dimension, get metadata from the ensemble metadata
        else
            ensMeta = var.ensMeta{d};
            
            % If the ensemble metadata is empty, use NaN
            if isempty(ensMeta)
                ensMeta = NaN;
            end
        end
    
        % If taking a mean along a state dimension
        if var.takeMean(d) && var.isState(d)

            % Place the metadata collection in a cell (unless already a
            % scalar cell).
            if ~iscell(ensMeta) || size(ensMeta,1)>1
                ensMeta = {ensMeta};
            end

            % Replicate over the set of all indices
            ensMeta = repmat( ensMeta, [nEls, 1]);
        
        % Otherwise
        else
            
            % Subscript index each metadata value. (And preserve any
            % inherent dimensionality.)
            ensMeta = indexMetadata( ensMeta, subDex(:,d) );
            
            % Convert to cell if numeric. Preserve dimensionality.
            if ~iscell(ensMeta)
                groupDim = 2:ndims(ensMeta);
                ensMeta = num2cell(ensMeta, groupDim);
            end
        end
        
        % Add to ensemble metadata
        meta.(var.dimID(d))(varDex{v}) = ensMeta;
    end
end

end