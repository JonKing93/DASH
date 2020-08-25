function[v] = variableIndex(obj, varNames)
%% Returns the indices of state vector variables in the stateVector 
% variables array. Returns an error if any variables do not exist.
%
% v = obj.variableIndex(varNames)
%
% ----- Inputs -----
%
% varNames: The names of the variables. A string vector or cellstring vector.
%
% ----- Outputs -----
%
% v: The indices in the stateVector variables array.

listName = sprintf('variable in %s', obj.errorTitle);
v = dash.checkStrsInList(varNames, obj.variableNames, 'varNames', listName);

end