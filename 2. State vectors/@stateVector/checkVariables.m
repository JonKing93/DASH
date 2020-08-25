function[v] = checkVariables(obj, varNames, multiple)
%% Returns the indices of state vector variables in the stateVector 
% variables array. Returns an error if any variables do not exist.
% Optionally checks that only a single variable is provided.
%
% v = obj.checkVariables(varNames)
%
% ----- Inputs -----
%
% varNames: The names of the variables. A string vector or cellstring vector.
%
% multiple: A scalar logical. Indicates whether multiple variables are
%    allowed as input (true) or just one variable (false).
%
% ----- Outputs -----
%
% v: The indices in the stateVector variables array.

% Process singular inputs
name = 'varNames';
if ~multiple
    name = 'varName';
    dash.assertStrFlag(varName, name);
end

% Check the variables are in the state vector and get their indices
listName = sprintf('variable in %s', obj.errorTitle);
v = dash.checkStrsInList(varNames, obj.variableNames, name, listName);

end