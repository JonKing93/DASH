function[rows] = findVariableRows(obj, varName, indices)
% Work on the wording.
%
%% Finds the state vector rows that for elements of the portion of a state
% vector correpsonding to a variable.
%
% rows = obj.findVariableRows(varName, indices)
%
% ----- Inputs -----
%
% varName: The name of a variable in a state vector. A string.
%
% indices: Indices along the portion of the state vector corresponding to
%    the variable. May either be a set of linear indices, or a logical
%    vector with one element per state vector element in the variable.
%
% ----- Outputs -----
%
% rows: The location of the indices in the full state vector.

% Error check variable, get index
varName = dash.assertStrFlag(varName, 'varName');
v = dash.checkStrsInList(varName, obj.variableNames, 'varName', 'variable in the state vector');

% Error check the indices
name = sprintf('the number of state vector elements for variable "%s"', varName);
indices = dash.checkIndices(indices, 'indices', obj.nEls(v), name);

% Get row in complete state vector.
rows = indices + obj.varLimit(v,1) - 1;

end