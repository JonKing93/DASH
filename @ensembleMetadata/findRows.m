function[rows] = findRows(obj, varName, varRows)
%% Finds the state vector rows that correspond to elements of a specific
% variable in a state vector.
%
% rows = obj.findRows(varName, varRows)
%
% ----- Inputs -----
%
% varName: The name of a variable in a state vector. A string.
%
% varRows: Elements of the state vector for the variable.
%
% ----- Outputs -----
%
% rows: The rows of the variable's elements in the state vector.

% Error check variable, get index
varName = dash.assertStrFlag(varName, 'varName');
v = dash.checkStrsInList(varName, obj.variableNames, 'varName', 'variable in the state vector');

% Error check the indices
name = sprintf('the number of state vector elements for variable "%s"', varName);
varRows = dash.checkIndices(varRows, 'varRows', obj.nEls(v), name);

% Get row in complete state vector.
rows = varRows + obj.varLimit(v,1) - 1;

end