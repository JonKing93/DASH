function[dimensions] = dimensions(obj, variables, type, cellOutput)
%% stateVector.dimensions  Return the dimensions associated with state vector variables
% ----------
%   dimensions = <strong>obj.dimensions</strong>
%   dimensions = <strong>obj.dimensions</strong>(-1)
%   Return the names of dimensions associated with each variable in the
%   state vector.
%
%   dimensions = <strong>obj.dimensions</strong>(v)
%   dimensions = <strong>obj.dimensions</strong>(variableNames)
%   Return the names of dimensions associated with the specified state
%   vector variables.
%
%   dimensions = <strong>obj.dimensions</strong>(..., type)
%   dimensions = <strong>obj.dimensions</strong>(..., 0|'a'|'all'|[])
%   dimensions = <strong>obj.dimensions</strong>(..., 1|'s'|'state')
%   dimensions = <strong>obj.dimensions</strong>(..., 2|'e'|'ens'|'ensemble')
%   Specify the type of dimension to return for each variable. Options are
%   all dimensions, state dimensions, or ensemble dimensions. By default,
%   returns all dimensions for each variable.
%
%   dimensions = <strong>obj.dimensions</strong>(..., type, cellOutput)
%   dimensions = <strong>obj.dimensions</strong>(..., type, true|'c'|'cell')
%   dimensions = <strong>obj.dimensions</strong>(..., type, false|'d'|'default')
%   Specify whether output should always be organized in a cell. If false
%   (default), dimensions for a single variable are returned as a string row
%   vector. If true, dimensions for a single variable are returned as a
%   string row vector within a scalar cell. Dimensions for multiple variables
%   are always returned as a cell vector of string row vectors.
% ----------
%   Inputs:
%       v (vector, logical | linear indices [nVariables] | -1): The indices of the variables
%           in the state vector for which to return dimension names. If -1,
%           selects all variables in the state vector.
%       variableNames (string vector [nVariables]): The names of variables
%           in the state vector for which to return dimension names.
%       cellOutput (scalar logical | string scalar): Whether to always
%           return output as a cell. When false (default), dimensions for a single variable are 
%           returned as a string row vector. If true, dimensions for a single
%           variable are returned as a string row vector within a scalar cell.
%
%   Outputs:
%       dimensions (string row vector | cell vector [nVariables] {string row vector}):
%           The dimensions associated with each specified variable. If
%           multiple variables are specified, dimensions is a cell vector
%           with one element per variable. Each element holds the names of
%           the dimensions associated with the variable. If a single
%           variable is specified and cellOutput is false, returns the list
%           of dimensions directly as a string row vector.
%
% <a href="matlab:dash.doc('stateVector.dimensions')">Documentation Page</a>

% Setup
header = "DASH:stateVector:dimensions";
dash.assert.scalarObj(obj, header);
obj.assertUnserialized;

% Parse dimension type
if ~exist('type','var') || isempty(type)
    type = 0;
else
    switches = {["a","all"],["s","state"],["e","ens","ensemble"]};
    type = dash.parse.switches(type, switches, 1, 'type', 'recognized dimension type', header);
end
typeStrings = ["all","state","ensemble"];
type = typeStrings(type+1);

% Parse cell output
if ~exist('cellOutput','var') || isempty(cellOutput)
    cellOutput = false;
else
    switches = {["d","default"], ["c","cell"]};
    cellOutput = dash.parse.switches(cellOutput, switches, 1, 'cellOutput',...
        'allowed option', header);
end

% Parse variable indices
if ~exist('variables','var') 
    variables = -1;
end
vars = obj.variableIndices(variables, true, header);

% Preallocate
nVars = numel(vars);
dimensions = cell(nVars, 1);

% Get the dimension names
for k = 1:numel(vars)
    v = vars(k);
    dimensions{k} = obj.variables_(v).dimensions(type);
end

% Optionally extract single variable output from cell
if numel(dimensions)==1 && ~cellOutput
    dimensions = dimensions{1};
end

end