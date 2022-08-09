function[metadata] = getMetadata(obj, variable, dimension)
%% stateVector.getMetadata  Return the metadata along a dimension of a state vector variable
% ----------
%   metadata = <strong>obj.getMetadata</strong>(v, dimension)
%   metadata = <strong>obj.getMetadata</strong>(variableName, dimension)
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
%       variableName (string scalar): The name of a variable in the state
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
obj.assertUnserialized;

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
% error if loading fails
grid = obj.gridfile(v);
[metadata, failed, cause] = obj.variables_(v).getMetadata(d, grid, header);
if failed
    couldNotLoadMetadataError(obj, v, dimension, grid, cause, header)
end

end

% Error
function[] = couldNotLoadMetadataError(obj, v, dimension, grid, cause, header)

% Rethrow non-DASH error handling
if ~contains(cause.identifier, 'DASH')
    rethrow(cause);
end

% Dimension, variable, vector names
vector = '';
if ~strcmp(obj.label)
    vector = sprintf('in %s', obj.name);
end
var = obj.variables(v);

% Information about failure
id = cause.identifier;
if contains(id, 'couldNotBuildGridfile')
    [~,name] = fileparts(grid);
    info = sprintf([', because the gridfile for the variable (%s) failed to ',...
        'build.\n\ngridfile: %s'], name, grid);
elseif contains(id, 'invalidGridfile')
    [~,name] = fileparts(grid);
    info = sprintf([', because the gridfile for the variable (%s) does not ',...
        'match the gridfile used to create the variable.\n\ngridfile: %s'], name, grid);
elseif contains(id, 'conversionFunctionFailed')
    info = ', because the conversion function for the metadata failed to run.';
elseif contains(id, 'invalidConversion')
    info = [', because the conversion function for the metadata did not produce ',...
        'a valid metadata matrix.'];
elseif contains(id, 'metadataSizeConflict')
    info = ', because the output of the metadata conversion function has the wrong number of rows.';
else
    info = '.';
end

% Throw error
id = sprintf('%s:couldNotLoadMetadata', header);
ME = MException(id, ['Could not load metadata for the "%s" dimension of the ',...
    '"%s" variable%s%s'], dimension, var, vector, info);
ME = addCause(ME, cause.cause{1});
throwAsCaller(ME);

end