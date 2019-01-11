function[ensDex, ix] = getCoupledEnsIndex( var, dim, meta )
%% This gets the coupled state indices for a dimension of a variable by 
% matching a metadata template.

% Get the dimension index
d = checkVarDim( var, dim );

% Get the metadata for the variable in the correct dimension
dimMeta = metaGridfile( var.file );
dimMeta = dimMeta.( var.dimID{d} );

% Check for repeated metadata
if numel(unique(dimMeta)) ~= numel(dimMeta)
    error('The template metadata contains repeat values.');
end

% Singleton dimensions are allowed to use NaN metadata
if numel(dimMeta)==1 && isequaln(meta, dimMeta)
    ensDex = 1;
    
% Otherwise, get the intersecting values
else
    [~, ensDex, ix] = intersect( dimMeta, meta );
    
    % Throw error if there are no indices
    if isempty(ensDex)
        error('The %s variable does not have metadata matching any state indices of the template variable.', var.name );
    end
end
end

