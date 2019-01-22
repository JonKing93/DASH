function[nameDex] = varCheck( ensMeta, name )
%% Checks for a variable name field and returns variable indices

% Check that the metadata has a variable name field
[~,var] = getKnownIDs;
if ~isfield(ensMeta, var)
    error('Ensemble metadata must contain the %s field.', var);
end

% Check that the name is a string
if ~(isstring(name)&&isscalar(name)) && ~(ischar(name)&&isvector(name))
    error('Variable name must be a string.');
end

% Get the indices of the name
nameDex = find( ismember( ensMeta.(var), name ) );

end
