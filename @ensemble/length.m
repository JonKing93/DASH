function[lengths] = length(obj, variables, scope)
%% ensemble.length  Returns the number of state vector rows for an ensemble
% ----------
%   length = obj.length
%   length = obj.length(0)
%   Returns the number of elements in the state vector for the ensemble. If
%   the "useVariables" command has been applied to the ensemble, only
%   counts elements of the variables being used by the ensemble.
%
%   lengths = obj.length(variableNames)
%   lengths = obj.length(v)
%   lengths = obj.length(-1)
%   Returns the lengths of the specified variables. Variable names and
%   indices are interpreted in the context of variables being used by the
%   ensemble. If the index is -1, selects all variables being used.
%
%   length = obj.length(0, scope)
%   ... = obj.length(0, "used"|"u"|false)
%   ... = obj.length(0, "file"|"f"|true)
%   Indicate the scope in which to return the length of the state vector.
%   If "used"|"u"|false, counts elements in variables being used by the
%   ensemble. If "file"|"f"|true, counts elements in all variables saved in
%   the .ens file.
%
%   lengths = obj.length(variables, scope)
%   ... = obj.length(variables, "used"|"u"|false)
%   ... = obj.length(variables, "file"|"f"|true)
%   Indicate the scope in which to interpret variable names and indices. If
%   "used"|"u"|false, interprets names and indices in the context of
%   variables being used by the state vector. If "file"|"f"|true,
%   interprets names and indices in the context of all variables saved in
%   the .ens file.
% ----------
%   Inputs:
%       v (0 | -1 | vector, linear indices): The indices of variables for
%           which to return lengths. If 0, returns the full length of the
%           state vector, rather than individual variable lengths. If -1, returns
%           the lengths of every variable. Depending on scope, these
%           indices are interpreted with respect to either the variables
%           being used by the ensemble, or the variables saved in the .ens file.
%       variableNames (string vector): The names of variables for which to
%           return lengths. Depending on scope, these names must either be
%           the names of used variables, or the names of variables saved in
%           the .ens file.
%       scope (string scalar | logical scalar): The scope in which to
%           interpret indices and return lengths
%           ["used"|"u"|true (default)]: Return lengths relative to the set
%               of variables being used by the ensemble object.
%           ["file"|"f|false]: Return lengths relative to the set of all
%               variables stored in the .ens file.
%
%   Outputs:
%       length (scalar integer): The total length of the state vector.
%       lengths (vector, integers): The lengths of the specified variables.
%
% <a href="matlab:dash.doc('ensemble.length')">Documentation Page</a>

% Setup
header = "DASH:ensemble:length";
dash.assert.scalarObj(obj, header);

% Defaults
if ~exist('variables','var')
    variables = 0;
end
if ~exist('scope', 'var')
    scope = "used";
end

% Note if returning the sum of variable lengths
takeSum = false;
if isequal(variables, 0)
    takeSum = true;
    variables = -1;
end

% Parse indices and scope
v = obj.variableIndices(variables, scope, header);

% Get lengths and optionally take sum
lengths = obj.lengths(v);
if takeSum
    lengths = sum(lengths);
end

end