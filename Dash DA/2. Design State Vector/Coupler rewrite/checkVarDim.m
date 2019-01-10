function[d] = checkVarDim( var, dim )
%% Error check a variable design and dimension and gets the dimension index.

if ~isa(var, 'varDesign')
    error('var must be a varDesign.');
end
[ismem, d] = ismember(dim,var);
if any(~ismem)
    error('Unrecognized dimension %s.', dim(find(~ismem,1)) );
end

end