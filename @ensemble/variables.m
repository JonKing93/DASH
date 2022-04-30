function[variableNames] = variables(obj, v, scope)
%% ensemble.variables  Return the names of variables in an ensemble
% ----------
%   variableNames = obj.variables
%   variableNames = obj.variables(-1)
%   Returns the ordered list of variables in the ensemble. The index of
%   each variable in the list corresponds to the index of the variable in
%   the ensemble. If the "useVariables" command has been applied to the
%   ensemble, only returns the names and indices of the variables being
%   used by the ensemble object.
%
%   variableNames = obj.variables(v)
%   Returns the list of variables at the specified variable indices. The
%   order of variables in the list corresponds to the order of input
%   indices. If the "useVariables" command has been applied to the
%   ensemble, interprets variable indices with respect to the variables
%   being used by the ensemble object.
%
%   variableNames = obj.variables(..., scope)
%   variableNames = obj.variables(..., false|"u"|"used")
%   variableNames = obj.variables(...,  true|"f"|"file")
%   Indicates the scope in which to consider specified variables. If false,
%   behaves identically to the previous syntaxes - variable names and
%   indices are interpreted relative to the variables being used by the
%   ensemble object. 
% 
%   If true, variable names and indices are interpreted and returned
%   relative to all the variables stored in the .ens file, including
%   variables not currently used by the ensemble object. When the first
%   input is -1, returns the list of all variables saved in the .ens file.
%   Otherwise, interprets variable indices relative to the full set of
%   saved variables. 
% ----------

% Setup
header = "DASH:ensemble:variables";
dash.assert.scalarObj(obj, header);

% Defaults
if ~exist('v','var') || isempty(v)
    v = -1;
end
if ~exist('scope','var') || isempty(scope)
    scope = false;
end

% Parse scope and variables
v = obj.variableIndices(v, scope, header);

% Return names
variableNames = obj.variables_(v);

end