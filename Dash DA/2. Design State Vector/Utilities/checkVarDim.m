function[d] = checkVarDim( var, dim )
%% Error check a variable design and dimension and gets the dimension index.

if ~isa(var, 'varDesign')
    error('var must be a varDesign.');
end
[ismem, d] = ismember(dim,var);
if any(~ismem)
    error('Variable %s does not contain dimension %s.', var.name, dim(find(~ismem,1)) );
end

end