function[index, ix] = getMatchingMetaDex( var, dim, meta, isState )
%% This gets indices of a dimensions of a specific variables that match a
% metadata template.

% Get the dimension index
d = checkVarDim( var, dim );

% Get the metadata for the variable in the dimension
dimMeta = var.meta.(dim);

% Check for repeated metadata
if numel(unique(dimMeta)) ~= numel(dimMeta)
    error('The metadata template contains repeat values in the %s dimension.', dim);
end

% Singleton dimensions are allowed to use NaN metadata
if numel(dimMeta)==1 && isequaln(meta, dimMeta)
    index = 1;
    
    % Otherwise, get intersecting value
else
    [~, index, ix] = intersect( dimMeta, meta );
    
    % Throw error if there are no indices
    if isempty(ensDex)
        error('The %s variable does not have metadata matching any of the template metadata.');
    end
    
    % If a state index, throw error if there are missing indices
    if isState && numel(index)~=numel(meta)
        error('The %s variable does not have metadata matching all state indices of the template variable.', var.name );
    end
end

end