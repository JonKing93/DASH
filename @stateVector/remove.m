function[obj] = remove(obj, variables)
%% stateVector.remove  Remove variables from a state vector
% ----------
%   obj = obj.remove(v)
%   obj = obj.remove(variableNames)
%   Removes the specified variables from a state vector.
%
%   obj = obj.remove(-1)
%   Removes all variables from a state vector.
% ----------
%   Inputs:
%       v (logical vector [nVariables] | vector, linear indices): The
%           indices of the variables that should be removed from the state vector.
%       variableNames (string vector): The names of the variables that
%           should be removed from the state vector.
% 
%   Outputs:
%       obj (scalar stateVector object): The updated stateVector object
%           with variables removed.
%
% <a href="matlab:dash.doc('stateVector.remove')">Documentation Page</a>

% Setup
header = "DASH:stateVector:remove";
dash.assert.scalarObj(obj, header);
obj.assertEditable;
obj.assertUnserialized;

% Error check variables, get indices
if isequal(variables, -1)
    v = 1:obj.nVariables;
else
    v = obj.variableIndices(variables, true, header);
end

% Remove variables
obj.variableNames(v,:) = [];
obj.variables_(v,:) = [];
obj.gridfiles(v,:) = [];
obj.allowOverlap(v,:) = [];
obj.lengths(v,:) = [];

obj.coupled(v,:) = [];
obj.coupled(:,v) = [];
obj.autocouple_(v,:) = [];

obj.nVariables = numel(obj.variables_);

end