function[obj] = design(obj, d, isstate, indices, header)
%% dash.stateVectorVariable.design  Design the dimensions of a state vector variable
% ----------
%   obj = obj.design(d, isstate, indices)
%   Designs the specified dimensions given the dimension types and
%   state/reference indices for the dimensions.
% ----------
%   Inputs:
%       d (vector, linear indices [nDimensions]): The indices of the
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

% Default
if ~exist('header','var') || isempty(header)
    header = "DASH:stateVectorVariable:design";
end

% Error check state and reference indices
nDims = numel(d);
dash.assert.indexCollection(indices, nDims, obj.gridSize(d), obj.dims(d), header);

% Update each dimension
for k = 1:nDims
    if isstate(k)
        obj = stateDimension(obj, d(k), indices{k}, header);
    else
        obj = ensembleDimension(obj, d(k), indices{k}, header);
    end
end

end

% Utility functions
function[obj] = stateDimension(obj, d, indices, header)

% Update design
obj.stateSize(d) = obj.gridSize(d);
if ~isempty(indices)
    obj.stateSize(d) = numel(indices);
end
obj.ensSize(d) = 1;
obj.isState(d) = true;

% Use column indices
if isrow(indices)
    indices = indices';
end
obj.indices{d} = indices;

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
    weightsSizeConflictError(obj, d, header);
end

% Reset mean properties
obj.meanIndices{d} = [];
if obj.meanType~=0
    obj.meanSize(d) = obj.stateSize(d);
    obj.stateSize(d) = 1;
end

end
function[obj] = ensembleDimension(obj, d, indices, header)

% Check for a conflict with mean indices if converting from state
if obj.isState(d) && obj.meanType(d)~=0
    noMeanIndicesError(obj, d, header);
end

% If converting from state, set sequence indices
if obj.isState(d)
    obj.sequenceIndices{d} = 0;
    obj.sequenceMetadata{d} = [];
end

% Update design
obj.stateSize(d) = numel(obj.sequenceIndices{d});
obj.isState(d) = false;

obj.ensSize(d) = obj.gridSize(d);
if ~isempty(indices)
    obj.ensSize(d) = numel(indices);
end

% Use column indices
if isrow(indices)
    indices = indices';
end
obj.indices{d} = indices;

% Check for metadata size conflict
if obj.metadataType(d)==1 && size(obj.metadata{d},1)~=obj.ensSize
    metadataSizeConflictError(obj, d, header);
end

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
nMeta = size(obj.metadata{d},1);
id = sprintf('%s:metadataSizeConflict', header);
ME = MException(id, ...
    ['The number of reference indices (%.f) for dimension "%s" does not\n',...
    'match the number of rows of the user-specified metadata (%.f rows).\n',...
    'Either use %.f reference indices or reset the metadata options.'],...
    obj.ensSize(d), obj.dims(d), nMeta, nMeta);
throwAsCaller(ME);
end