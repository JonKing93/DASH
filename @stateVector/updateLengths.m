function[obj] = updateLengths(obj, vars)
%% stateVector.updateLengths  Updates the state vector lengths of variables in a state vector
% ----------
%   obj = <strong>obj.updateLengths</strong>(vars)
%   Updates the state vector lengths of the specified variables.
% ----------
%   Inputs:
%       vars (vector, linear indices): The indices of the variables whose
%           state vector lengths should be updated.
%
%   Outputs:
%       obj (scalar stateVector object): The state vector with updated
%           variable lengths.
%
% <a href="matlab:dash.doc('stateVector.updateLengths')">Documentation Page</a>

for k = 1:numel(vars)
    v = vars(k);
    sizes = obj.variables_(v).stateSizes;
    obj.lengths(v) = prod(sizes);
end

end