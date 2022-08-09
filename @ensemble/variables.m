function[variableNames] = variables(obj, v, scope)
%% ensemble.variables  Return the names of variables in an ensemble
% ----------
%   variableNames = <strong>obj.variables</strong>
%   Returns the ordered list of variables in the ensemble. The index of
%   each variable in the list corresponds to the index of the variable in
%   the ensemble. If the "useVariables" command has been applied to the
%   ensemble, only returns the names and indices of the variables being
%   used by the ensemble object.
%
%   variableNames = <strong>obj.variables</strong>(v)
%   variableNames = <strong>obj.variables</strong>(-1)
%   Returns the list of variables at the specified variable indices. The
%   order of variables in the list corresponds to the order of input
%   indices. Variable indices are interpreted in the context of variables
%   being used by the ensemble. If the index is -1, selects all used
%   variables.
%
%   variableNames = <strong>obj.variables</strong>(v, scope)
%   Indicate the scope in which to interpret variable indices. If
%   false|"u"|"used", behaves identically to the previous syntax and
%   interprets indices in the context of variables being used by the
%   ensemble. If true|"f"|"file", interprets indices in the context of
%   variables saved in the .ens file. If the index is -1, returns the names
%   of all variables within the appropriate scope.
% ----------
%   Inputs:
%       v (-1 | logical vector | linear indices): The indices of variables in the
%           ensemble whose names should be returned. If -1, selects all
%           variables. Depending on scope, these indices are interpreted in
%           the context of either the variables being used by the ensemble,
%           or the variables saved in the .ens file.
%       scope (string scalar | logical scalar): The scope in which to
%           interpret indices and return variable names
%           ["used"|"u"|true (default)]: Return names relative to the set
%               of variables being used by the ensemble object.
%           ["file"|"f|false]: Return names relative to the set of all
%               variables stored in the .ens file.
%
%   Outputs:
%       variableNames (string vector): The names of the specified variables
%
% <a href="matlab:dash.doc('ensemble.variables')">Documentation Page</a>

% Setup
header = "DASH:ensemble:variables";
dash.assert.scalarObj(obj, header);

% Defaults
if ~exist('v','var')
    v = -1;
end
if ~exist('scope','var')
    scope = "used";
end

% Parse indices and scope
v = obj.variableIndices(v, scope, header);

% Get names
variableNames = obj.variables_(v);

end