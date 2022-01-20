function[obj] = sequence(obj, dims, indices, metadata, header)

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
