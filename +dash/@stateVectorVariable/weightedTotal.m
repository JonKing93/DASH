function[obj] = weightedTotal(obj, dims, weights, header)
%% dash.stateVectorVariable.weightedTotal  Apply a weighted total to dimensions of a state vector variable
% ----------
%   obj = <strong>obj.weightedTotal</strong>(dims, weights, header)
%   Takes a weighted total over the indicated dimensions.
% ----------
%   Inputs:
%       dims (vector, linear indices [nDimensions]): The indices of the
%           ensemble dimensions to update.
%       weights (cell vector [nDimensions] {numeric vector}): Weights to
%           use for each dimension.
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       obj (scalar dash.stateVectorVariable object): The variable with
%           updated weighted total parameters.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.weightedTotal')">Documentation Page</a>

% Cycle through dimensions, skip missing dimensions
for k = 1:numel(dims)
    d = dims(k);
    if d==0
        continue;
    end

    % Prevent conflict with means
    if ismember(obj.meanType(d), [1 2])
        existingMeanError(obj, d, header);
    end

    % If a new total, require state dimension. Update sizes and type
    if obj.meanType(d) == 0
        if ~obj.isState(d)
            noTotalIndicesError(obj, d, header);
        end
        obj.meanSize(d) = obj.stateSize(d);
        obj.stateSize(d) = 1;
        obj.meanType(d) = 4;
    end

    % If weights are empty, remove weights and downgrade total type
    if isempty(weights{k})
        obj.meanType(d) = 3;
        obj.weights{d} = [];
        continue;
    end

    % Check for size conflicts
    nWeights = numel(weights{k});
    if nWeights ~= obj.meanSize(d)
        weightsSizeConflictError(obj, d, nWeights, header);
    end

    % Update type and weights
    obj.meanType(d) = 4;
    obj.weights{d} = weights{k}(:);
end

end

% Error messages
function[] = existingMeanError(obj, d, header)
dim = obj.dims(d);
id = sprintf("%s:existingMean", header);
ME = MException(id, ...
    ['You cannot call the "weightedTotal" command on the "%s" dimension because you are\n',...
    'already implementing a mean over the dimension. If you want to use\n',...
    'the "weightedTotal" command for this dimension, you will first need to disable\n',...
    'the mean by calling the "mean" command with the "none" option for "%s".'],...
    dim, dim);
throwAsCaller(ME);
end
function[] = noTotalIndicesError(obj, d, header)
dim = obj.dims(d);
id = sprintf('%s:noTotalIndices', header);
link = '<a href="matlab:dash.doc(''stateVector.total'')">stateVector.total</a>';
ME = MException(id, ...
    ['Cannot take a weighted total over the "%s" dimension because "%s" is\n',...
    'an ensemble dimension, but does not have any total indices. Consider\n',...
    'using the %s method to provide total indices for the "%s" dimension.'],...
    dim, dim, link, dim);
throwAsCaller(ME);
end
function[] = weightsSizeConflictError(obj, d, nWeights, header)

if obj.isState(d)
    indexType = 'state';
    link = '<a href="matlab:dash.doc(''stateVector.design'')">stateVector.design method</a>';
else
    indexType = 'total';
    link = '<a href="matlab:dash.doc(''stateVector.total'')">stateVector.total method</a>';
end

dim = obj.dims(d);
id = sprintf('%s:wrongNumberOfWeights', header);
ME = MException(id, ...
    ['Cannot take a weighted total over the "%s" dimension because the number\n',...
    'of weights (%.f) does not match the number of %s indices (%.f). Either\n',...
    'change the number of weights, or use the %s to ',...
    'change the number of %s indices.'],...
    dim, nWeights, indexType, obj.meanSize(d), link, indexType);
throwAsCaller(ME);
end

