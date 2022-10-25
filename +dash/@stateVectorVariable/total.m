function[obj] = total(obj, dims, indices, omitnan, header)
%% dash.stateVectorVariable.total  Take a total over dimensions of a state vector variable
% ----------
%   obj = <strong>obj.total</strong>(dims, indices, omitnan, header)
%   Takes a total over the specified dimensions given total indices and NaN
%   options.
%
%   obj = <strong>obj.total</strong>(dims, "none", [], header)
%   Disables the total over the specified dimensions.
%
%   obj = <strong>obj.total</strong>(dims, "unweighted", [], header)
%   Discards weights for weighted totals of the specified dimensions.
% ----------
%   Inputs:
%       dims (vector, linear indices [nDimensions]): The indices of the
%           dimensions over which to take a total.
%       indices (cell vector [nDimensions] {[] | total indices}): Total
%           indices for the dimensions. An empty array for state
%           dimensions, and additive indices for ensemble dimensions.
%       omitnan (logical vector [nDimensions]): Whether to omit NaN
%           elements along a total (true) or whether to include NaN (false)
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       obj (scalar dash.stateVectorVariable object): The variable updated
%           with the new total parameters.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.total')">Documentation Page</a>

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

    % Either disable total, or set new values
    if isequal(indices, "none")
        obj = disableTotal(obj, d);
    elseif isequal(indices, "unweighted")
        obj = disableWeights(obj, d, header);
    else
        obj = setTotal(obj, d, indices{k}, omitnan(k), header);
    end
end

end

% Utility functions
function[obj] = disableTotal(obj, d)

% Restore state dimension size
if obj.isState(d) && obj.meanType(d)~=0
    obj.stateSize(d) = obj.meanSize(d);
end

% Reset all settings
obj.meanType(d) = 0;
obj.meanSize(d) = 0;
obj.meanIndices{d} = [];
obj.omitnan(d) = false;
obj.weights{d} = [];

end
function[obj] = disableWeights(obj, d, header)

% Check the dimension has a total
if obj.meanType(d) == 0
    noTotalToUnweightError(obj, d, header);
end

% Discard weights
obj.meanType(d) = 3;
obj.weights{d} = [];

end
function[obj] = setTotal(obj, d, indices, omitnan, header)

% State dimension - prohibit indices
if obj.isState(d)
    if ~isempty(indices)
        totalIndicesNotAllowedError(obj, d, header);
    end

    % Update size
    if obj.meanType(d)==0
        obj.meanSize(d) = obj.stateSize(d);
        obj.stateSize(d) = 1;
    end

% Ensemble dimension - require indices
else
    if isempty(indices)
        missingTotalIndicesError(obj, d, header);
    end
    nIndices = numel(indices);

    % Require index magnitude to be smaller than the dimension length
    [maxMagnitude, loc] = max(abs(indices));
    if maxMagnitude >= obj.gridSize(d)
        indexMagnitudeTooLargeError(obj, d, maxMagnitude, loc, header);
    end

    % Check for size conflict with weights
    if obj.meanType(d)==4 && nIndices~=obj.meanSize(d)
        weightsSizeConflictError(obj, d, nIndices, header);
    end

    % Update size
    obj.meanSize(d) = nIndices;
    obj.meanIndices{d} = indices(:);
end

% Update type and omitnan
if obj.meanType(d)==0
    obj.meanType(d) = 3;
end
obj.omitnan(d) = omitnan;

end

% Error messages
function[] = existingMeanError(obj, d, header)
dim = obj.dims(d);
id = sprintf("%s:existingMean", header);
ME = MException(id, ...
    ['You cannot call the "total" command on the "%s" dimension because you are\n',...
    'already implementing a mean over the dimension. If you want to use\n',...
    'the "total" command for this dimension, you will first need to disable\n',...
    'the mean by calling the "mean" command with the "none" option for "%s".'],...
    dim, dim);
throwAsCaller(ME);
end
function[] = noTotalToUnweightError(obj, d, header)
dim = obj.dims(d);
id = sprintf('%s:noTotalToUnweight', header);
ME = MException(id, ...
    ['Cannot unweight the total for the "%s" dimension because there is no\n',...
    'total over the "%s" dimension.'], dim, dim);
throwAsCaller(ME);
end
function[] = totalIndicesNotAllowedError(obj, d, header)
dim = obj.dims(d);
id = sprintf('%s:totalIndicesNotAllowed', header);
ME = MException(id, ...
    ['You cannot provide total indices for the "%s" dimension because it is\n',...
    'a state dimension.'], dim);
throwAsCaller(ME);
end
function[] = missingTotalIndicesError(obj, d, header)
dim = obj.dims(d);
id = sprintf('%s:missingTotalIndices', header);
ME = MException(id, ...
    ['You must provide total indices for the "%s" dimension because it is\n',...
    'an ensemble dimension.'], dim);
throwAsCaller(ME);
end
function[] = weightsSizeConflictError(obj, d, nIndices, header)
dim = obj.dims(d);
nWeights = obj.meanSize(d);
id = sprintf('%s:weightsSizeConflict', header);
ME = MException(id, ...
    ['You previously specified a weighted total for the "%s" dimension, and\n',...
    'the number of total indices (%.f) does not match the number of weights (%.f).\n',...
    'Either change the number of total indices, disable the weighted total, or\n',...
    'update the weights.'], dim, nIndices, nWeights);
throwAsCaller(ME);
end
function[] = indexMagnitudeTooLargeError(obj, d, maxMagnitude, loc, header)

id = sprintf('%s:totalIndexMagnitudeTooLarge', header);
ME = MException(id, [...
    'Cannot take a total over the "%s" dimension because the\n', ...
    'magnitude of total index %.f (%.f) is not smaller than\n',...
    'the length of the dimension (%.f).'],...
    obj.dims(d), loc, maxMagnitude, obj.gridSize(d));
throwAsCaller(ME);
end