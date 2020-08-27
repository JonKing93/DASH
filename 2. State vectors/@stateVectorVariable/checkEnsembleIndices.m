function[d] = checkEnsembleIndices(obj, dim, indices)
%% Checks that a dimension is an ensemble dimension and that indices are
% valid sequence or mean indices. Returns the index of the dimension.
%
% d = obj.checkEnsembleIndices(dim, indices)
%
% ----- Inputs -----
%
% dim: The dimension name being checked
%
% indices: The sequence or mean indices being checked
%
% ----- Outputs -----
%
% d: The dimension index

% Error check indices
dash.assertVectorTypeN(indices, 'numeric', [], 'indices');
if any(mod(indices,1)~=0)
    error('"indices" must be a vector of integers.');
elseif any(abs(indices)>obj.gridSize(d))
    bad = find(abs(indices)>obj.gridSize(d),1);
    error('Element %.f of indices (%.f) has a magnitude larger than the length of the %s dimension in variable %s (%.f).', bad, indices(bad), obj.dims(d), obj.name, obj.gridSize(d));
end

end