function[obj] = design(obj, dims, isstate, indices, header)
%% dash.stateVectorVariable.design  Design the dimensions of a state vector variable
% ----------
%   obj = <strong>obj.design</strong>(dims, isstate, indices, header)
%   Designs the specified dimensions given the dimension types and
%   state/reference indices for the dimensions.
% ----------
%   Inputs:
%       dims (vector, linear indices [nDimensions]): The indices of the
%           dimensions to design.
%       isstate (logical vector [nDimensions]): True if a dimension is a
%           state dimension. False if the dimension is an ensemble dimension.
%       indices (cell vector [nDimensions] {[] | logical vector | vector, linear indices}:
%           State or reference indices for each dimension.
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       obj (scalar dash.stateVectorVariable object): The variable updated
%           with the new design parameters.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.design')">Documentation Page</a>

% Cycle through dimensions. Skip missing dimensions
for k = 1:numel(dims)
    d = dims(k);
    if d==0
        continue;
    end

    % Error check state and reference indices
    name = sprintf('Indices for the "%s" dimension', obj.dims(d));
    linearMax = sprintf('the length of the "%s" dimension', obj.dims(d));
    logicalRequirement = sprintf('be %s', linearMax);
    dash.assert.indices(indices{k}, obj.gridSize(d), name, logicalRequirement, linearMax, header);

    % Update the dimension
    if isstate(k)
        obj = stateDimension(obj, d, indices{k}, header);
    else
        obj = ensembleDimension(obj, d, indices{k}, header);
    end
end

end

% Utility functions
function[obj] = stateDimension(obj, d, indices, header)

% Get the new size
newSize = obj.gridSize(d);
if ~isempty(indices)
    newSize = numel(indices);
end

% Check for size conflict with mean weights
if obj.meanType(d)==2 && obj.meanSize(d)~=newSize
    weightsSizeConflictError(obj, d, header);
end

% Update design
obj.stateSize(d) = newSize;
obj.ensSize(d) = 1;
obj.isState(d) = true;

% Record indices as column vectors
if isrow(indices)
    indices = indices';
end
obj.indices{d} = indices;

% Reset sequences
obj.sequenceIndices{d} = [];
obj.sequenceMetadata{d} = [];

% Reset metadata options
obj.metadataType(d) = 0;
obj.metadata_{d} = [];
obj.convertFunction{d} = [];
obj.convertArgs{d} = [];

% Update mean properties, remove mean indices
obj.meanIndices{d} = [];
if obj.meanType~=0
    obj.meanSize(d) = obj.stateSize(d);
    obj.stateSize(d) = 1;
end

end
function[obj] = ensembleDimension(obj, d, indices, header)

% Get the new size
newSize = obj.gridSize(d);
if ~isempty(indices)
    newSize = numel(indices);
end

% Check for metadata size conflict
if obj.metadataType(d)==1 && newSize~=obj.ensSize(d)
    metadataSizeConflictError(obj, d, header);
end

% If converting from a state dimension, check for conflict with mean
% indices and initialize sequence indices
if obj.isState(d)
    if obj.meanType(d)~=0
        noMeanIndicesError(obj, d, header);
    end
    obj.sequenceIndices{d} = 0;
end

% Update design
obj.stateSize(d) = numel(obj.sequenceIndices{d});
obj.ensSize(d) = newSize;
obj.isState(d) = false;

% Record indices as column
if isrow(indices)
    indices = indices';
end
obj.indices{d} = indices;

end

% Error messages
function[] = weightsSizeConflictError(obj, d, header)
id = sprintf('%s:weightsSizeConflict', header);
ME = MException(id, ...
    ['Cannot convert the "%s" dimension to a state dimension because %s is\n',...
    'being used in a weighted mean, and the number of state indices (%.f)\n',...
    'does not match the number of weights (%.f). Either specify %.f state indices\n',...
    'or reset the options for the weighted mean.'],...
    obj.dims(d), obj.stateSize(d), obj.meanSize(d), obj.meanSize(d));
throwAsCaller(ME);
end
function[] = noMeanIndicesError(obj, d, header)
id = sprintf('%s:noMeanIndices', header);
ME = MException(id, ...
    ['Cannot convert dimension "%s" to an ensemble dimension because it is\n',...
    'being used in a mean and there are no mean indices. You may want to\n',...
    'reset the options for the mean.'], obj.dims(d));
throwAsCaller(ME);
end
function[] = metadataSizeConflictError(obj, d, header)
nMeta = size(obj.metadata_{d},1);
id = sprintf('%s:metadataSizeConflict', header);
ME = MException(id, ...
    ['The number of reference indices (%.f) for dimension "%s" does not\n',...
    'match the number of rows of the user-specified metadata (%.f rows).\n',...
    'Either use %.f reference indices or reset the metadata options.'],...
    obj.ensSize(d), obj.dims(d), nMeta, nMeta);
throwAsCaller(ME);
end