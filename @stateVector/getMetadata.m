function[metadata] = getMetadata(obj, variable, dimension)
%% stateVector.getMetadata  Return the metadata along a dimension of a state vector variable
% ----------
%   metadata = obj.getMetadata(v, dimension)
%   metadata = obj.getMetadata(variableName, dimension)
%   Returns the metadata that will be used along a dimension of a variable.
%   If the dimension is a state dimension, returns the gridfile metadata at
%   the specified state indices. If the dimension is an ensemble dimension,
%   returns either 1. The raw gridfile metadata at the reference indices,
%   2. Alternate user-specified metadata, or 3. gridfile metadata processed
%   via a metadata conversion function. Which of these three types is
%   returned will vary depending on previous use of the
%   "stateVector.metadata" method.
% ----------
%   Inputs:
%       v (scalar linear index | logical vector): The index of a variable
%           in the state vector for which to return metadata. Either a scalar
%           linear index or a logical vector with one element per state
%           vector variable. If a logical vector, must have exactly one
%           true element.
%       variableNames (string scalar): The name of a variable in the state
%           vector for which to return metadata.
%       dimension (string scalar): The name of a dimension of the variable
%           for which to return metadata.
%
%   Outputs:
%       metadata (matrix, numeric | logical | char | string | datetime):
%           The metadata of data elements along the dimension that will be
%           used in the state vector.
%
% <a href="matlab:dash.doc('stateVector.getMetadata')">Documentation Page</a>

% Setup
header = "DASH:stateVector:getMetadata";
dash.assert.scalarObj(obj, header);

% Check variable, get index
v = obj.variableIndices(variable, true, header);
v = unique(v);
if numel(v)>1
    id = sprintf('%s:tooManyVariables', header);
    error(id, ['You can only return metadata for a single variable, but ',....
        'you have requested metadata for %.f variables'], numel(v));
end

% Check dimension, get index
dimension = dash.assert.strflag(dimension, 'dimension', header);
d = obj.dimensionIndices(v, dimension, header);

% Extract metadata. Let variable build gridfile if necessary. Informative
% error if gridfile fails.
grid = obj.gridfile(v);
try
    metadata = obj.variables_(v).getMetadata(d, grid, header);
catch ME
    couldNotLoadMetadataError(obj, v, dimension, ME, header);
end

end

% Error
function[] = couldNotLoadMetadataError(obj, v, dimension, cause, header)

if ~contains(cause.identifier, 'DASH')
    rethrow(cause);
end

vector = '';
if ~strcmp(obj.label)
    vector = sprintf('in %s', obj.name);
end

id = sprintf('%s:couldNotLoadMetadata', header);

ME = MException(id, ['Could not load metadata for the "%s" dimension of the ',...
    '"%s" variable%s.'], dimension, obj.variables(v), vector);
ME = addCause(ME, cause);
throwAsCaller(ME);

end