function[indices] = dimensionIndices(obj, v, dimensions, header)
%% stateVector.dimensionIndices  Return the indices of named dimensions in state vector variables
% ----------
%   indices = obj.dimensionIndices(v, dimensions)
%   Return the indices of the named dimensions in the specified state
%   vector variables. Throws an error if a named dimension is not associated
%   with a specified variable.
%
%   indices = obj.dimensionIndices(v, dimensions, header)
%   Customize thrown error IDs.
% ----------
%   Inputs:
%       v (vector [nVariables], linear indices): The indices of the state vector
%           variables for which to return dimension indices.
%       dimensions (string vector [nDimensions]): The names of dimensions that will be
%           indexed in the specified variables.
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       indices (cell vector [nVariables], {vector [nDimensions], linear indices}):
%           The indices of the named dimensions in the specified variables.
%
% <a href="matlab:dash.doc('stateVector.dimensionIndices')">Documentation Page</a>

% Default
if ~exist('header','var') || isempty(header)
    header = "DASH:stateVector:dimensionIndices";
end

% Initial error check
dimensions = dash.assert.strlist(dimensions);
dash.assert.uniqueSet(dimensions, 'dimensions', header);

% Preallocate dimension indices for each variable
nVars = numel(v);
indices = cell(nVars, 1);

% Get the dimensions for each variable. Get the index for each variable
variableDimensions = obj.dimensions(v, true);
for k = 1:nVars
    variableName = obj.variableNames(v(k));
    listName = sprintf('dimension of the "%s" variable', variableName);
    indices{v} = dash.assert.strsInList(dimensions, variableDimensions{v}, ...
        'Dimension', listName, header);
end

end