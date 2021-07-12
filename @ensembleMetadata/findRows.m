function[rows] = findRows(obj, varName, varRows)
%% Finds the state vector rows that correspond to elements of a specific
% variable in a state vector.
%
% rows = obj.findRows(varName)
% rows = obj.findRows(varName, 'all')
% Returns the rows of all state vector elements associated with the
% specified variable.
%
% rows = obj.findRows(varName, 'end')
% Returns the last state vector row associated with a variable.
%
% rows = obj.findRows(varName, varRows)
% Takes rows from a variable's state vector and locates the corresponding
% rows in the complete state vector that contains all variables.
%
% ----- Inputs -----
%
% varName: The name of a variable in a state vector. A string.
%
% varRows: Elements of the variable's state vector. Either a set of linear
%    indices or a logical vector with one element per state vector element
%    for the variable.
%
% ----- Outputs -----
%
% rows: The rows of the variable's elements in the state vector.

% Error check variable, get index
varName = dash.assert.strFlag(varName, 'varName');
v = dash.assert.strsInList(varName, obj.variableNames, 'varName', 'variable in the state vector');

% Parse secondary inputs
if ~exist('varRows','var') || isempty(varRows) || isequal(varRows, 'all')
    varRows = 1:obj.nEls(v);
elseif isequal(varRows,'end') || isequal(varRows, "end")
    varRows = obj.nEls(v);
else
    name = sprintf('the number of state vector elements for variable "%s"', varName);
    varRows = dash.assert.indices(varRows, 'varRows', obj.nEls(v), name);
end

% Get rows in complete state vector.
rows = varRows + obj.varLimit(v,1) - 1;

end