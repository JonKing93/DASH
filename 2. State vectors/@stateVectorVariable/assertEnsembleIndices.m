function[] = assertEnsembleIndices(obj, indices, d, name)
%% Checks that an input is a valid set of sequence or mean indices.
%
% d = obj.assertEnsembleIndices(indices, d, name)
%
% ----- Inputs -----
%
% input: The sequence or mean indices being checked
%
% d: Dimension index for the indices
%
% name: The name of the input. A string.

dash.assertVectorTypeN(indices, 'numeric', [], 'indices');
if any(mod(indices,1)~=0)
    error('%s must be a vector of integers.', name);
elseif any(abs(indices)>obj.gridSize(d))
    error('%s cannot have values with a magnitude larger than %.f (the length of the %s dimension in variable %s).', name, obj.gridSize(d), obj.dims(d), obj.name);
end

end