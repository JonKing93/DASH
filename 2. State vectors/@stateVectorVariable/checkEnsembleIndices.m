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

% Error check the dimension. Only ensemble dimensions are allowed
d = obj.checkDimensions(dim, false);
if obj.isState(d)
    error('Only ensemble dimensions can have mean indices, but %s (in variable %s) is a state dimension in variable %s. To make %s an ensemble dimension, see "stateVector.design".', obj.dims(d), obj.name, obj.name, obj.dims(d));
end

% Error check indices
dash.assertVectorTypeN(indices, 'numeric', [], 'indices');
if any(mod(indices,1)~=0)
    error('"indices" must be a vector of integers.');
elseif any(abs(indices)>obj.gridSize(d))
    bad = find(abs(indices)>obj.gridSize(d),1);
    error('Element %.f of indices (%.f) has a magnitude larger than the length of the %s dimension in variable %s (%.f).', bad, indices(bad), obj.dims(d), obj.name, obj.gridSize(d));
end

end