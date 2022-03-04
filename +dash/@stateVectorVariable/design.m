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
    indices{k} = dash.assert.indices(indices{k}, obj.gridSize(d), name, logicalRequirement, linearMax, header);

    % Get the new size of the dimension
    if isempty(indices{k})
        newSize = obj.gridSize(d);
    else
        newSize = numel(indices{k});
    end

    % Check for size conflicts with alternate metadata
    if obj.metadataType(d)==1
        nMeta = size(obj.metadata_{d},1);
        if newSize ~= nMeta
            metadataSizeConflictError(obj, d, newSize, nMeta, header);
        end
    end

    % Update the dimension
    if isstate(k)
        obj = stateDimension(obj, d, newSize, header);
    else
        obj = ensembleDimension(obj, d, newSize, header);
    end

    % Record indices as column vector
    if isrow(indices{k})
        indices{k} = indices{k}';
    end
    obj.indices{d} = indices{k};
end

end

% Utility functions
function[obj] = stateDimension(obj, d, newSize, header)

% Check for size conflicts with weights
if obj.meanType(d)==2 && obj.meanSize(d)~=newSize
    weightsSizeConflictError(obj, d, newSize, header);
end

% Update design
obj.stateSize(d) = newSize;
obj.ensSize(d) = 1;
obj.isState(d) = true;

% Reset sequences
obj.hasSequence(d) = false;
obj.sequenceIndices{d} = [];
obj.sequenceMetadata{d} = [];

% Update mean properties, remove mean indices
obj.meanIndices{d} = [];
if obj.meanType(d)~=0
    obj.meanSize(d) = newSize;
    obj.stateSize(d) = 1;
end

end
function[obj] = ensembleDimension(obj, d, newSize, header)

% If converting from a state dimension, check for conflict with mean
% indices and initialize sequence indices
if obj.isState(d)
    if obj.meanType(d)~=0
        noMeanIndicesError(obj, d, header);
    end
end

% Update design
if obj.hasSequence(d)
    obj.stateSize(d) = numel(obj.sequenceIndices{d});
else
    obj.stateSize(d) = 1;
end
obj.ensSize(d) = newSize;
obj.isState(d) = false;

end

% Error messages
function[] = weightsSizeConflictError(obj, d, nIndices, header)
id = sprintf('%s:weightsSizeConflict', header);
ME = MException(id, ...
    ['The "%s" dimension is being used in a weighted mean, but the number\n',...
    'of state indices (%.f) does not match the number of weights (%.f).\n',...
    'Either specify %.f state indices or reset the options for the weighted mean.'],...
    obj.dims(d), nIndices, obj.meanSize(d), obj.meanSize(d));
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
function[] = metadataSizeConflictError(obj, d, nIndices, nMeta, header)
if obj.isState(d)
    type = 'state';
else
    type = 'reference';
end
id = sprintf('%s:metadataSizeConflict', header);
ME = MException(id, ...
    ['The number of %s indices (%.f) for dimension "%s" does not\n',...
    'match the number of rows of the user-specified metadata (%.f rows).\n',...
    'Either use %.f %s indices or reset the metadata options.'],...
    type, nIndices, obj.dims(d), nMeta, nMeta, type);
throwAsCaller(ME);
end