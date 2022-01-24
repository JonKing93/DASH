function[indices, dimensions] = dimensionIndices(obj, v, dimensions, header)
%% stateVector.dimensionIndices  Return the indices of named dimensions in state vector variables
% ----------
%   indices = obj.dimensionIndices(v, dimensions)
%   Return the indices of the named dimensions in the specified state
%   vector variables. Throws an error if a named dimension is not associated
%   with any of the listed variables.
%
%   [indices, dimensions] = obj.dimensionIndices(v, dimensions)
%   Also return the dimension names as a "string" data type.
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
%       dimensions (string vector [nDimensions]): The names of dimensions
%           converted to a "string" data type.
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
nDims = numel(dimensions);
nVars = numel(v);
indices = NaN(nVars, nDims);

% Get the dimensions and index for each variable
variableDimensions = obj.dimensions(v, true);
for k = 1:nVars
    [~, indices(k,:)] = ismember(dimensions, variableDimensions{k});
end

% Throw error if a dimension isn't in any variable
missing = all(indices==0, 1);
if any(missing)
    bad = find(missing,1);
    badName = dimensions(bad);
    id = sprintf('%s:dimensionNotInVariables', header);
    error(id, ['Dimension %.f (%s) is not associated with any of the listed ',...
        'variables.'], bad, badName);
end

end