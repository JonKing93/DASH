function[lengths] = length(obj, variables, scope)
%% ensemble.length  Returns the number of state vector rows for an ensemble
% ----------
%   length = obj.length
%   length = obj.length(0)
%   Return the number of elements in the state vector for the ensemble
%   object. If the "useVariables" command has been applied to the ensemble,
%   only considers elements of the variables being used by the ensemble
%   object.
%
%   lengths = obj.length(-1)
%   Returns the number of state vector elements for each variable in the
%   ensemble. If the "useVariables" command has been applied to the ensemble,
%   only returns the lengths of variables being used by the ensemble object.
%   The order of lengths corresponds to the order of variables being used
%   by the ensemble object.
%
%   lengths = obj.length(v)
%   lengths = obj.length(variableNames)
%   Returns the lengths of the specified variables. If the "useVariables"
%   command has been applied to the ensemble object, interprets variable
%   names and indices in the context of variables being used by the
%   ensemble object.
%
%   ... = obj.length(..., scope)
%   ... = obj.length(..., false|"u"|"used")
%   ... = obj.length(...,  true|"f"|"file")
%   Indicates the scope in which to consider variables. If false,
%   interprets values in the context of variables being used by the
%   ensemble object. This option behaves identically to the previous
%   syntaxes. 
% 
%   If true, interprets values in the context of all variables saved in the
%   .ens file, including variables not being used by the ensemble object.
%   If the first input is 0, returns the lengths of the full state vector
%   saved in the .ens file. If the first input is -1, returns the lengths
%   of all variables saved in the .ens file. Otherwise, interprets variable
%   names and indices in the context of all variables saved in the .ens file.
% ----------

% Setup
header = "DASH:ensemble:length";
dash.assert.scalarObj(obj, header);

% Defaults
if ~exist('variables','var') || isempty(variables)
    variables = 0;
end
if ~exist('scope','var') || isempty(scope)
    scope = false;
end

% Note whether to sum over variables
returnSum = false;
if isequal(variables, 0)
    returnSum = true;
    variables = -1;
end

% Parse scope and variables.
v = obj.variableIndices(variables, scope);

% Get lengths, optionally take sum
lengths = obj.lengths(v);
if returnSum
    lengths = sum(lengths);
end

end