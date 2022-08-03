function[obj] = uncouple(obj, variables)
%% stateVector.uncouple  Uncouple variables in a state vector
% ----------
%   obj = obj.uncouple
%   obj = obj.uncouple(-1)
%   Uncouples all the variables in the state vector from on another. The
%   variables are not required to have matching metadata within individual
%   ensemble members. Variables will also no longer be automatically
%   coupled to new variables added to the state vector.
%
%   obj = obj.uncouple(v)
%   obj = obj.uncouple(variableNames)
%   Uncouples each of the listed variables from all other variables in the
%   state vector. The uncoupled variables are not required to match the 
%   metadata of other variables within individual ensemble members. The
%   uncoupled variables will also not be automatically coupled to new
%   variables added to the state vector.
% ----------
%   Inputs:
%       v (logical vector | linear indices | -1): The indices of variables in
%           the state vector that should be uncoupled. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices. If -1, selects all variables in the state
%           vector.
%       variableNames (string vector): The names of variables in the state
%           vector that should be uncoupled.
%
%   Outputs:
%       obj (scalar stateVector object): The state vector with updated
%           uncoupled variables.
%
% <a href="matlab:dash.doc('stateVector.uncouple')">Documentation Page</a>

% Setup
header = "DASH:stateVector:uncouple";
dash.assert.scalarObj(obj, header);
obj.assertEditable;

% Get variable indices
if ~exist('variables','var')
    variables = -1;
end
v = obj.variableIndices(variables, true, header);

% Uncouple
obj.coupled(v,:) = false;
obj.coupled(:,v) = false;
obj.coupled(1:obj.nVariables+1:end) = true;

% Diable autocoupling
obj.autocouple_(v) = false;

end