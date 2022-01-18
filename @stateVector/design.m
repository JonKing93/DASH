function[obj] = design(obj, variables, dimensions, type, indices)
%% stateVector.design  Design the dimensions of variables in a state vector
% ----------

% Setup
header = "DASH:stateVector:design";
obj.assertEditable;
vars = obj.variableIndices(variables);

% Error check dimensions, get index in each variable
dimensions = dash.assert.strlist(dimensions, 'dimensions', header);
dims = obj.dimensionIndices(dimensions, vars);

% Parse dimension types
nDims = numel(dimensions);
isState = dash.parse.logicalOrString(type, nDims, otherArgs);

% Parse indices
if ~exist('indices','var')
    indices = cell(1, nDims);
else
    dash.assert.indexCollection(indices, nDims, [], dimNames, header);
end

% Error check the indices for each variable
for v = 1:numel(vars)
    checkIndices(obj, v, dims(v,:), indices, header)

    % Update the variable's dimensions. Skip dimensions not in the variable
    for d = 1:nDims
        if dims(v,d)~=0
            obj.variables(v) = updateDimension(obj, v, dims(v,d), isState(d), indices{d}, header);
        end
    end
end

end

% Utility subfunctions
function[] = checkIndices(obj, v, d, indices, header)

% Get the variable
var = obj.variables(v);

% Ignore indices for dimensions that are not in the variable
ignore = d==0;
d(ignore) = [];
indices(ignore) = [];

% Get the dimensions, and lengths
dims = var.dims(d);
dimLengths = var.gridSize(d);

% Check that each set of indices is compatible with the grid dimensions
for d = 1:numel(dims)
    lengthName = sprintf('the length of the "%s" dimension', dims(d));
    try
        indices{d} = dash.assert.indices(indices{d}, dimLengths(d), dims(d), lengthName(d), header);

    % Supplement error messages if not
    catch ME
        designError(obj, v, dims(d), ME);
    end
end

end
function[var] = updateDimension(obj, v, d, indices, header)

% Get the variable
var = obj.variables(v);

% Get the size of the new dimension
newSize = var.gridSize(d);
if ~isempty(indices)
    newSize = numel(indices);
end

% State dimension: Check for size conflicts with weights, then update
if isState
    if var.hasWeights(d) && newSize~=var.meanSize(d)
        weightsSizeConflictError(newSize, var.meanSize(d), obj, v, d, header);
    end
    var = var.stateDimension(d, indices);

% Ensemble dimension: Check for size conflicts with mean indices and
% metadata, then update
else
    if var.isState(d) && var.takeMean(d)
        noMeanIndicesError(obj, v, d, header);
    elseif var.hasMetadata(d) && newSize~=size(var.metadata{d},1)
        metadataSizeConflictError(newSize, size(var.metadata{d},1), obj, v, d, header);
    end
    var = var.ensembleDimension(d, indices);
end

end

% Error messages
function[] = designError(obj, v, d, cause)


varName = obj.variableNames(v);
dimName = obj.variables(v).dims(d);

% Optionally include state vector name in the error message
tail = '';
name = obj.name;
if ~strcmp(name,"") && ~isempty(name)
    tail = sprintf('\nState Vector: %s',name);
end

message = sprintf([...
    'Cannot design the "%s" dimension of the "%s" variable',...
    '\n\n',...
    '%s',...
    '\n\n',...
    '   Dimension: %s\n',...
    '    Variable: %s',...
    '%s'],...
    dimName, varName, cause.message, dimName, varName, tail);

error(cause.identifier, '%s', message);

end
function[] = weightsSizeConflictError(stateSize, nWeights, obj, v, d, header)
id = sprintf('%s:weightsSizeConflict', header);
ME = MException(id, ['Cannot convert the "%s" dimension to a state dimension',...
    'because %s is being used in a weighted mean, and the number of state ',...
    'indices (%.f) does not match the number of weights (%.f). Either specify ',...
    '%.f state indices or reset the options for the weighted mean.'],...
    obj.variables(v).dims(d), stateSize, nWeights, nWeights);
designError(obj, v, d, ME);
end
function[] = noMeanIndicesError(obj, v, d, header)
id = sprintf('%s:noMeanIndices', header);
ME = MException(id, ['Cannot convert dimension "%s" to an ensemble dimension ',...
    'because it is being used in a mean and there are no mean indices. You may ',...
    'want to reset the options for the mean.'], obj.variables(v).dims(d));
designError(obj, v, d, ME);
end
function[] = metadataSizeConflictError(ensSize, metaSize, obj, v, d, header)
id = sprintf('%s:metadataSizeConflict', header);
ME = MException(id, ['The number of reference indices (%.f) for dimension "%s"',...
    'does not match the number of rows of the user-specified metadata (%.f rows).',...
    'Either use %.f reference indices or reset the metadata options.'],...
    ensSize, obj.variables(v).dims(d), metaSize, ensSize);
designError(obj, v, d, ME);
end