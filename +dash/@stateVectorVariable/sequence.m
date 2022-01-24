function[obj] = sequence(obj, dims, indices, metadata, header)
%% dash.stateVectorVariable.sequence  Apply a sequence to ensemble dimensions of a state vector variable
% ----------
%   obj = <strong>obj.sequence</strong>(dims, indices, metadata, header)
%   Applies sequences to the indicated ensemble dimensions.
% ----------
%   Inputs:
%       dims (vector, linear indices [nDimensions]): The indices of the
%           ensemble dimensions to update.
%       indices (cell vector [nDimensions] {additive indices [nIndices]}): The
%           sequence indices to use for each dimension.
%       metadata (cell vector [nDimensions] {metadata matrix [nIndices x ?]}):
%           The sequence metadata to use for each dimension
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       obj (scalar dash.stateVectorVariable object): The variable with
%           updated sequence parameters.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.sequence')">Documentation Page</a>

% Only allow ensemble dimensions
if any(obj.isState(dims))
    stateDimensionError(obj, dims, header);
end

% Cycle through dimensions.
for k = 1:numel(dims)
    d = dims(k);

    % Remove sequences from a dimension
    if isempty(indices{k})
        obj.stateSize(d) = 1;
        obj.sequenceIndices{d} = 0;
        obj.sequenceMetadata{d} = [];

    % Add sequence to a dimension
    else
        obj.stateSize(d) = numel(indices{k});
        obj.sequenceIndices{d} = indices{k}(:);
        obj.sequenceMetadata{d} = metadata{k};
    end
end

end

% Error messages
function[] = stateDimensionError(obj, dims, header)
isState = obj.isState(dims);
bad = find(isState, 1);
d = dims(bad);
dim = obj.dims(d);
link = '<a href="matlab:dash.doc(''stateVector.design'')">stateVector.design</a>';

id = sprintf('%s:sequenceOfStateDimension', header);
ME = MException(id, ...
    ['Cannot apply a sequence to the "%s" dimension because "%s" is not an\n',...
    'ensemble dimension. Either remove "%s" from the list of sequenced\n',...
    'dimensions, or convert it to an ensemble dimension using %s.'],...
    dim, dim, dim, link);
throwAsCaller(ME);
end
