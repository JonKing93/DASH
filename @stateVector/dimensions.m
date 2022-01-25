function[dimensions] = dimensions(obj, variables, cellOutput)
%% stateVector.dimensions  Return the dimensions associated with state vector variables
% ----------
%   dimensions = obj.dimensions
%   dimensions = obj.dimensions([])
%   dimensions = obj.dimensions(0)
%   Return the names of dimensions associated with each state vector
%   variable.
%
%   dimensions = obj.dimensions(v)
%   dimensions = obj.dimensions(variableNames)
%   Return the names of dimensions associated with the specified state
%   vector variables.
%
%   dimensions = obj.dimensions(..., cellOutput)
%   Specify whether output should always be organized in a cell. If false
%   (default), dimensions for a single variable are returned as a string row
%   vector. If true, dimensions for a single variable are returned as a
%   string row vector within a scalar cell. Dimensions for multiple variables
%   are always returned as a cell vector of string row vectors.
% ----------
%   Inputs:
%       v (vector, logical | linear indices [nVariables]): The indices of the variables
%           in the state vector for which to return dimension names.
%       variableNames (string vector [nVariables]): The names of variables
%           in the state vector for which to return dimension names.
%       cellOutput (scalar logical): Whether to always return output as a
%           cell. When false (default), dimensions for a single variable are 
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

% Parse cell output
if ~exist('cellOutput','var') || isempty(cellOutput)
    cellOutput = false;
else
    dash.assert.scalarType(cellOutput, 'logical', 'cellOutput', header);
end

% Parse variable indices
if ~exist('variables','var') || isempty(variables) || isequal(variables, 0)
    v = 1:obj.nVariables;
else
    v = obj.variableIndices(variables, true, header);
end

% Get the dimension names
dimensions = {obj.variables_(v).dimensions}';

% Optionally remove single variable output from cell
if numel(dimensions)==1 && ~cellOutput
    dimensions = dimensions{1};
end

end