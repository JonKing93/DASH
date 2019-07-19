function[meta] = ensembleMetadata( design )
%% Generates the ensemble metadata for an ensemble.
%
% meta = ensembleMetadata( design )
%
% ----- Inputs -----
%
% design: A state vector design
%
% ----- Outputs -----
%
% meta: The metadata structure for an ensemble built from the state vector
%       design.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the state indices associated with each variable
[varDex, varDim] = getVarIndices( design.var );

% Get the total number of state elements
nState = sum( prod(varDim,2) , 1);

% Initialize an empty metadata container with a row for each state element.
meta = initializeMeta( design, nState );

% For each variable
for v = 1:numel(design.var)
    var = design.var(v);
    
    % Record the index limits
    meta.varLim(v,:) = [min(varDex{v}), max(varDex{v})];
    
    % Get the number of elements for the variable
    nEls = prod( varDim(v,:) );
    
    % Get the N-dimensional subscript indices
    subDex = subdim( varDim(v,:) , (1:nEls)' );
    
    % For each dimension
    for d = 1:numel(var.dimID)
        
        % If a state dimension, get metadata from grid metadata
        if var.isState(d)
            ensMeta = var.meta.(var.dimID(d))( var.indices{d}, : );
            
        % If an ensemble dimension, get metadata from the ensemble metadata
        else
            ensMeta = var.seqMeta{d};
            
            % If the ensemble metadata is empty, use NaN
            if isempty(ensMeta)
                ensMeta = NaN;
            end
        end
    
        % If taking a mean along a state dimension
        if var.takeMean(d) && var.isState(d)
            
            % Propagate the metadata collection along the third dimension
            ensMeta = permute(ensMeta, [3 2 1]);

            % Replicate over the set of all indices
            ensMeta = repmat( ensMeta, [nEls, 1]);
        
        % Otherwise
        else
            
            % Subscript index each metadata value.
            ensMeta = ensMeta( subDex(:,d), : );
            
        end
        
        % Add to ensemble metadata
        meta.var(v).(var.dimID(d)) = ensMeta;
    end
end

end