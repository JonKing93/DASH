function[indices] = subscriptRows(obj, v, variableRows)
%% ensembleMetadata.subscriptRows  Return subscripted state dimension indices for rows of a variable
% ----------
%   indices = obj.subscriptRows(v, variableRows)
%   Given the rows of a variable in the state vector, returns the
%   subscript indices of the rows for each state dimension of the variable.
% ----------
%   Inputs:
%       v (scalar linear index): The index of a variable in the state vector
%       variableRows (vector, linear indices): The indices of rows for the
%           variable. Note that these rows are interpreted relative to the
%           variable, rather than the overall state vector. For example,
%           variableRows=1 returns the subscript indices for the first row
%           of the variable, regardless of its overall position in the
%           state vector.
%
%   Outputs:
%       indices (cell vector [nStateDims] {linear indices}): Subscript
%           indices of the rows across each of the variable's state
%           dimensions.
%
% <a href="matlab:dash.doc('ensembleMetadata.subscriptRows')">Documentation Page</a>

% Wrap rows in cell to allow defaulting
if ~exist('variableRows','var')
    variableRows = {};
else
    variableRows = {variableRows};
end

% Subscript the indices
indices = dash.indices.subscript(obj.stateSize{v}, variableRows{:});

end