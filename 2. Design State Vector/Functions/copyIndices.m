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
    meta = indexMetadata( X.meta.(X.dimID(dim)), X.indices{dim} );
    
    % For each copying variable
    for k = 1:numel(Y)
        
        % Get a dimension index
        d = checkVarDim( Y(k), X.dimID(dim) );
        
        % Get values for means
        Y(k).takeMean(d) = X.takeMean(dim);
        Y(k).nanflag{d} = X.nanflag{dim};
        
        % Get state indices with matching metadata
        currMeta = Y(k).meta.(X.dimID(dim));        
        Y(k).indices{d} = matchingMetaIndex( currMeta, meta );
      
        % If a state dimension
        if X.isState(dim)
            
            % Error check the indices
            if numel(Y(k).indices{d}) ~= size(meta,1)
                error('The %s variable does not have metadata matching all state indices of the template %s variable in the %s dimension.', Y(k).name, X.name, X.dimID(dim));
            end
            
            % Flip the isState toggle
            Y(k).isState(d) = true;
            
            % Delete seq, mean, and ensMeta
            Y(k).seqDex{k} = [];
            Y(k).meanDex{k} = [];
            Y(k).ensMeta{k} = [];
            
        % If an ensemble dimension and syncing seq or mean
        else
            
            % Error check ensemble indices
            if isempty( Y(k).indices{d} )
                error('The %s variable does not have metadata matching any of the metadata for the template variable %s in the %s dimension.', Y(k).name, X.name, X.dimID(dim) );
            end
            
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
