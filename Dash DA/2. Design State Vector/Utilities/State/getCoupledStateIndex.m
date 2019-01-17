function[stateDex] = getCoupledStateIndex( var, dim, meta )
%% This gets the coupled state indices for a dimension of a variable by 
% matching a metadata template.

% Get the dimension index
d = checkVarDim( var, dim );

% Get the metadata for the variable in the correct dimension
dimMeta = var.meta.(var.dimID{d});

% Check for repeated metadata
if numel(unique(dimMeta)) ~= numel(dimMeta)
    error('The template metadata contains repeat values in the %s dimension.', dim);
end

% Singleton dimensions are allowed to use NaN metadata
if numel(dimMeta)==1 && isequaln(meta, dimMeta)
    stateDex = 1;
    
% Otherwise, get the intersecting values
else
    [~, stateDex] = intersect( dimMeta, meta );
    
    % Throw error if there are missing indices
    if numel(stateDex) ~= numel(meta)
        error('The %s variable does not have metadata matching all state indices of the template variable.', var.name );
    end
end
end

