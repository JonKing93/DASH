function[d] = checkVarDim( var, dim )
%% Error check a variable design and dimension and gets the dimension index.

% Error check the variable
if ~isa(var, 'varDesign') || ~isscalar(var)
    error('var must be a scalar varDesign.');
end

% Check that the dim is a single string
if ischar(dim) && isrow(dim)
    dim = string(dim);
elseif ~isstring(dim) || ~isscalar(dim)
    error('dim must be a single string.')
end

% Get the location
[ismem, d] = ismember(dim,var.dimID);

% Ensure the dimension is in the variable
if ~ismem
    error('Variable %s does not contain dimension %s.', var.name, dim );
end

end