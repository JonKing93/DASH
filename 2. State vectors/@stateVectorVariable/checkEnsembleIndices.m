function[] = checkEnsembleIndices(obj, indices, d)
%% Checks that indices are a valid sequence or mean indices.
%
% d = obj.checkEnsembleIndices(indices)
%
% ----- Inputs -----
%
% indices: The sequence or mean indices being checked
%
% d: Dimension index for the indices

dash.assertVectorTypeN(indices, 'numeric', [], 'indices');
if any(mod(indices,1)~=0)
    error('"indices" must be a vector of integers.');
elseif any(abs(indices)>obj.gridSize(d))
    bad = find(abs(indices)>obj.gridSize(d),1);
    error('Element %.f of indices (%.f) has a magnitude larger than the length of the %s dimension in variable %s (%.f).', bad, indices(bad), obj.dims(d), obj.name, obj.gridSize(d));
end

end