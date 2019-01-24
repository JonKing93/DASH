function[d] = checkVarDim( var, dim )
%% Error check a variable design and dimension and gets the dimension index.
%
% var: varDesign
%
% dim: Dimension name
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error check the variable
if ~isa(var, 'varDesign') || ~isscalar(var)
    error('var must be a scalar varDesign.');
end

% Get the location
[ismem, d] = ismember(dim,var.dimID);

% Ensure the dimension is in the variable
if ~ismem
    error('Variable %s does not contain dimension %s.', var.name, dim );
end

end