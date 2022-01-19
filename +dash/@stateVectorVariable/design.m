function[obj] = design(obj, dimensions, isstate, indices, header)
%% dash.stateVectorVariable.design  Design the dimensions of a state vector variable
% ----------
%   obj = obj.design(dimensions, isstate, indices)
% ----------

% Error check dimensions, get indices
dims = obj.dimensionIndices(dimensions, header);

% Cycle through dimensions
for k = 1:numel(dims)
    d = dims(k);
    
    % Error check indices
    dimName = sprintf('the "%s" dimension', obj.dims(d));
    indicesName = sprintf('Indices for %s', dimName);
    logicalRequirement = sprintf('be the length of %s', dimName);
    linearMax = sprintf('the length of %s', dimName);
    indices{k} = dash.assert.indices(indices{k}, obj.gridSize(d), indicesName, logicalRequirement, linearMax, header);

    % Design state or ensemble dimensions
    if isstate(k)
        obj = stateDimension(obj, d, indices{k});
    else
        obj = ensembleDimension(obj, d, indices{k});
    end
end

end

% Utility functions
function[obj] = stateDimension(obj, d, indices)

% Update design
obj.stateSize(d) = obj.gridSize(d);
if ~isempty(indices)
    obj.stateSize(d) = numel(indices);
end
obj.indices{d} = indices;
obj.ensSize(d) = 1;

% Reset sequences
obj.sequenceIndices{d} = [];
obj.sequenceMetadata{d} = [];

% Reset metadata options
obj.metadataType(d) = 0;
obj.metadata{d} = [];
obj.convertFunction{d} = [];
obj.convertArgs{d} = [];

% Check for size conflict with mean weights
if obj.meanType(d)==3 && obj.meanSize(d)~=obj.stateSize(d)
    weightsSizeConflictError(obj, d);
end

% Reset mean properties
obj.meanIndices{d} = [];
if obj.meanType~=0
    obj.meanSize(d) = obj.stateSize(d);
    obj.stateSize(d) = 1;
end

end
function[obj] = ensembleDimension(obj, d, indices)

% Check for a conflict with mean indices if converting from state
if obj.isState(d) && obj.meanType~=0
    noMeanIndicesError;
end

% If converting from state, set sequence indices
if obj.isState(d)
    obj.sequenceIndices{d} = 0;
    obj.sequenceMetadata{d} = [];
end

% Update indices and sizes
obj.indices{d} = indices;
obj.stateSize(d) = numel(obj.sequenceIndices{d});

obj.ensSize(d) = obj.gridSize(d);
if ~isempty(indices)
    obj.ensSize(d) = numel(indices);
end

% Check for metadata size conflict
if obj.metadataType(d)==1 && size(obj.metadata{d},1)~=obj.ensSize
    metadataSizeConflictError;
end

end

% Error messages
function[] = weightsSizeConflictError(obj, d, header)
id = sprintf('%s:weightsSizeConflict', header);
ME = MException(id, ['Cannot convert the "%s" dimension to a state dimension ',...
    'because %s is being used in a weighted mean, and the number of state ',...
    'indices (%.f) does not match the number of weights (%.f). Either specify ',...
    '%.f state indices or reset the options for the weighted mean.'],...
    obj.dims(d), obj.stateSize(d), obj.meanSize(d), obj.meanSize(d));
throwAsCaller(ME);
end
function[] = noMeanIndicesError(obj, d, header)
id = sprintf('%s:noMeanIndices', header);
ME = MException(id, ['Cannot convert dimension "%s" to an ensemble dimension ',...
    'because it is being used in a mean and there are no mean indices. You may ',...
    'want to reset the options for the mean.'], obj.dims(d));
throwAsCaller(ME);
end
function[] = metadataSizeConflictError(obj, d, header)
nMeta = size(obj.metadata{d},1);
id = sprintf('%s:metadataSizeConflict', header);
ME = MException(id, ['The number of reference indices (%.f) for dimension "%s"',...
    'does not match the number of rows of the user-specified metadata (%.f rows).',...
    'Either use %.f reference indices or reset the metadata options.'],...
    obj.ensSize(d), obj.dims(d), nMeta, nMeta);
throwAsCaller(ME);
end