function[varNames] = variableNames(obj, v)
% Returns the names of the variables in a stateVector object.
%
% varNames = obj.variableNames;
% Returns the names of all variables in the state vector.
%
% varNames = obj.variableNames(v);
% Returns the names of the specified variables
%
% ----- Inputs -----
%
% v: The indices of specific variables within the state vector. A vector
%    of positive integers that do not exceed the number of variables OR a
%    logical vector with one element per variable.
%
% ----- Outputs -----
%
% varNames: A string vector of variable names.

% Default and error check for v
nVars = numel(obj.variables);
if ~exist('v','var') || isempty(v)
    v = 1:nVars;
elseif islogical(v) || isnumeric(v)
    v = dash.assert.indices(v, 'v', nVars, 'the number of variables');
else
    error('v must either be a logical or numeric vector.');
end

% Default for empty state vector
varNames = strings(0,1);

% Get the variable names
if ~isempty(obj.variables)
    varNames = dash.struct.collectField(obj.variables(v), 'name');
    varNames = string(varNames);
end

end