function[variableNames] = variables(obj, v)
%% stateVector.variables  Return the names of variables in a state vector
% ----------
%   variableNames = <strong>obj.variables</strong>
%   variableNames = <strong>obj.variables</strong>([])
%   variableNames = <strong>obj.variables</strong>(0)
%   Returns the ordered list of variables in a state vector. The index of
%   each variable in the list corresponds to the index of the variable in
%   the gridfile.
%
%   variableNames = <strong>obj.variables</strong>(v)
%   Returns the list of variables at the specified variable indices. The
%   order of variables in the list corresponds to the order of input
%   indices.
% ----------
%   Inputs:
%       v (logical vector [nVariables] | vector, linear indices): The
%           indices of the variables whose names should be returned in the
%           list.
%
%   Outputs:
%       variableNames (string vector): The list of variable names.
%
% <a href="matlab:dash.doc('stateVector.variables')">Documentation Page</a>

% Setup
header = "DASH:stateVector:variables";
dash.assert.scalarObj(obj, header);

% Parse indices
if ~exist('v','var') || isempty(v) || isequal(v,0)
    indices = [];
else
    logicalLength = sprintf('one element per variable in %s', obj.name);
    linearMax = sprintf('the number of variables in %s', obj.name);
    indices = dash.assert.indices(v, obj.nVariables, 'v', logicalLength, linearMax, header);
end

% List sources
variableNames = obj.variableNames(indices);

end