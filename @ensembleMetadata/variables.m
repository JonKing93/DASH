function[variableNames] = variables(obj, v)
%% ensembleMetadata.variables  Return the names of variables in a state vector ensemble
% ----------
%   variableNames = <strong>obj.variables</strong>
%   variableNames = <strong>obj.variables</strong>(-1)
%   Returns the ordered list of variables in a state vector ensemble. The
%   index of each variable in the list corresponds to the index of the
%   variable in the state vector.
%
%   variableNames = <strong>obj.variables</strong>(v)
%   Returns the list of variables at the specified variable indices. The
%   order of variables in the lsit corresponds to the order of input indices.
% ----------
%   Inputs:
%       v (-1 | logical vector | vector, linear indices): The indices of
%           variables whose names should be returned. If -1, selects all
%           variables in the state vector. If a logical vector, must have
%           one element per variable in the state vector. Otherwise, use
%           the linear indices of variables in the state vector.
%
%   Outputs:
%       variableNames (string vector): The list of variable names
%
% <a href="matlab:dash.doc('ensembleMetadata.variables')">Documentation Page</a>

% Setup
header = "DASH:ensembleMetadata:variables";
dash.assert.scalarObj(obj, header);

% Default and parse indices
if ~exist('v','var')
    v = -1;
end
v = obj.variableIndices(v, true, header);

% List variables
variableNames = obj.variables_(v);

end