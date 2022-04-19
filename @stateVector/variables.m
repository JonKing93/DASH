function[variableNames] = variables(obj, v)
%% stateVector.variables  Return the names of variables in a state vector
% ----------
%   variableNames = <strong>obj.variables</strong>
%   variableNames = <strong>obj.variables</strong>(-1)
%   Returns the ordered list of variables in a state vector. The index of
%   each variable in the list corresponds to the index of the variable in
%   the state vector.
%
%   variableNames = <strong>obj.variables</strong>(v)
%   Returns the list of variables at the specified variable indices. The
%   order of variables in the list corresponds to the order of input
%   indices.
% ----------
%   Inputs:
%       v (logical vector [nVariables] | vector, linear indices | -1): The
%           indices of the variables whose names should be returned in the
%           list. If -1, returns the name of every variable in the state
%           vector.
%
%   Outputs:
%       variableNames (string vector): The list of variable names.
%
% <a href="matlab:dash.doc('stateVector.variables')">Documentation Page</a>

% Setup
header = "DASH:stateVector:variables";
dash.assert.scalarObj(obj, header);

% Parse indices
if ~exist('v','var')
    v = -1;
end
indices = obj.variableIndices(v, true, header);

% List variables
variableNames = obj.variableNames(indices);

end