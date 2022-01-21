function[obj] = weightedMean(obj, dims, weights, header)

% Cycle through dimensions
for k = 1:numel(dims)
    d = dims(k);

    % Remove a weighted mean
    if isempty(weights{k})
        if obj.meanType(d)==2
            obj.meanType(d) = 1;
        end
        obj.weights{d} = [];

    % If updating an existing mean, check for size conflicts
    else
        if obj.meanType(d)~=0
            nWeights = numel(weights{k});
            if nWeights ~= obj.meanSize(d)
                weightsSizeConflictError(d, nWeights, header);
            end

        % If setting a new mean, require state dimension. Update size
        else
            if ~obj.isState(d)
                noMeanIndicesError(d, header);
            end
            obj.meanSize(d) = obj.stateSize(d);
            obj.stateSize(d) = 1;
        end

        % Update type and weights
        obj.meanType(d) = 2;
        obj.weights{d} = weights{k}(:);
    end
end

end

% Error messages
function[] = noMeanIndicesError(d, header)
dim = obj.dims(d);
id = sprintf('%s:noMeanIndices', header);
link = '<a href="matlab:dash.doc(''stateVector.mean'')">stateVector.mean</a>';
ME = MException(id, ...
    ['Cannot take a weighted mean over the "%s" dimension because "%s" is\n',...
    'an ensemble dimension, but does not have any mean indices. Consider\n',...
    'using the %s method to provide mean indices for the "%s" dimension.'],...
    dim, dim, link, dim);
throwAsCaller(ME);
end
function[] = weightsSizeConflictError(d, nWeights, header)

if obj.isState(d)
    indexType = 'state';
    link = '<a href="matlab:dash.doc(''stateVector.design'')">stateVector.design method</a>';
else
    indexType = 'mean';
    link = '<a href="matlab:dash.doc(''stateVector.mean'')">stateVector.mean method</a>';
end

dim = obj.dims(d);
id = sprintf('%s:wrongNumberOfWeights', header);
ME = MException(id, ...
    ['Cannot take a weighted mean over the "%s" dimension because the number\n',...
    'of weights (%.f) does not match the number of %s indices (%.f). Either\n',...
    'change the number of weights, or use the %s to change the number of %s indices.'],...
    dim, nWeights, indexType, obj.meanSize(d), link, indexType);
throwAsCaller(ME);
end









