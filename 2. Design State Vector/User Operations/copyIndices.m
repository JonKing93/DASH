function[design] = copyIndices( design, fromVar, toVars )
%% Copies all state, ensemble, sequence, and mean indices from a template 
% variable to other variables. State and ensemble indices are set the
% values with matching metadata. Also copies ensemble dimension metadata.
%
% design = copyIndices( design, fromVar, toVar )
% 
% ----- Inputs -----
%
% design: A state vector design
%
% fromVar: The template variable
%
% toVars: The variables into which indices will be copied.
%
% ----- Outputs -----
%
% design: The updated state vector design

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the template variable and copying variables
yv = unique( checkDesignVar(design, toVars) );
xv = checkDesignVar( design, fromVar );
if ~isscalar(xv)
    error('Template must be a single variable.');
end

% Get the template and copying variables
X = design.var(xv);
Y = design.var(yv);

% For each dimension
for dim = 1:numel(X.dimID)
    
    % Get the indexed metadata
    meta = indexMetadata( X.meta.(D.dimID{dim}), X.indices{dim} );
    
    % For each copying variable
    for k = 1:numel(Y)
        
        % Get a dimension index
        d = checkVarDim( Y(k), X.dimID{dim} );
        
        % Get values for means
        Y(k).takeMean(d) = X.takeMean(dim);
        Y(k).nanflag{d} = X.nanflag{dim};
        
        % Get indices with matching metadata
        Y(k).indices{d} = getMatchingMetaDex( Y(k), X.dimID{dim}, meta, true );
      
        % If a state dimension
        if X.isState(dim)
            
            % Flip the isState toggle
            Y(k).isState(d) = true;
            
        % If an ensemble dimension and syncing seq or mean
        else
            
            % Flip the isState toggle
            Y(k).isState(d) = false;
            
            % Get the sequence and mean indices
            Y(k).seqDex{d} = X.seqDex{dim};
            Y(k).meanDex{d} = X.meanDex{dim};
            
            % Copy ensemble metadata
            Y(k).ensMeta{d} = X.ensMeta{dim};
        end
    end
end

% Save edited variables to design
design.var(yv) = Y;

end
