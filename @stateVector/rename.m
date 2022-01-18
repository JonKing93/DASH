function[obj] = rename(obj, variables, newNames)
%% stateVector.rename  Renames variables in a state vector
% ----------
%   obj = obj.rename(v, newNames)
%   obj = obj.rename(variableNames, newNames)
%   Renames the specified variables to the provided new names.
% ----------
%   Inputs:
%       v (logical vector [nVariables] | vector, linear indices): The
%           indices of the variables that should be renamed.
%       variableNames (string vector): The names of the variables that
%           should be renamed.
%
%   Outputs:
%       obj (scalar stateVector object): The stateVector object updated
%           with the new variable names.
%
% <a href="matlab:dash.doc('stateVector.rename')">Documentation Page</a>

% Setup
header = "DASH:stateVector:rename";
dash.assert.scalarObj(obj, header);

% Error check variables, get indices
v = obj.variableIndices(variables, false, header);
nVariables = numel(v);

% Error check new names
newNames = dash.assert.strlist(newNames, 'newNames', header);
dash.assert.vectorTypeN(newNames, [], nVariables, 'newNames', header);
obj.assertValidNames(newNames, header);

% Rename
obj.variableNames(v) = newNames;

end
