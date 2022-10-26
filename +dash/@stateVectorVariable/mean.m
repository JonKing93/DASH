function[obj] = mean(obj, dims, indices, omitnan, header)
%% dash.stateVectorVariable.mean  Take a mean over dimensions of a state vector variable
% ----------
%   obj = <strong>obj.mean</strong>(dims, indices, omitnan, header)
%   Takes a mean over the specified dimensions given mean indices and NaN
%   options.
%
%   obj = <strong>obj.mean</strong>(dims, "none", [], header)
%   Disables the mean over the specified dimensions.
%
%   obj = <strong>obj.mean</strong>(dims, "unweighted", [], header)
%   Discards weights for weighted means of the specified dimensions.
% ----------
%   Inputs:
%       dims (vector, linear indices [nDimensions]): The indices of the
%           dimensions over which to take a mean.
%       indices (cell vector [nDimensions] {[] | mean indices}): Mean
%           indices for the dimensions. An empty array for state
%           dimensions, and additive indices for ensemble dimensions.
%       omitnan (logical vector [nDimensions]): Whether to omit NaN
%           elements along a mean (true) or whether to include NaN (false)
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       obj (scalar dash.stateVectorVariable object): The variable updated
%           with the new mean parameters.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.mean')">Documentation Page</a>

% Cycle through dimensions, skip missing dimensions
for k = 1:numel(dims)
    d = dims(k);
    if d==0
        continue;
    end

    % Prevent conflict with totals
    if ismember(obj.meanType(d), [3 4])
        existingTotalError(obj, d, header);
    end

    % Either disable mean, or set new values
    if isequal(indices, "none")
        obj = disableMean(obj, d);
    elseif isequal(indices, "unweighted")
        obj = disableWeights(obj, d, header);
    else
        obj = setMean(obj, d, indices{k}, omitnan(k), header);
    end
end

end

% Utility functions
function[obj] = disableMean(obj, d)

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

% Check the dimension has a mean
if obj.meanType(d) == 0
    noMeanToUnweightError(obj, d, header);
end

% Discard weights
obj.meanType(d) = 1;
obj.weights{d} = [];

end
function[obj] = setMean(obj, d, indices, omitnan, header)

% State dimension - prohibit indices
if obj.isState(d)
    if ~isempty(indices)
        meanIndicesNotAllowedError(obj, d, header);
    end

    % Update size
    if obj.meanType(d)==0
        obj.meanSize(d) = obj.stateSize(d);
        obj.stateSize(d) = 1;
    end

% Ensemble dimension - require indices
else
    if isempty(indices)
        missingMeanIndicesError(obj, d, header);
    end
    nIndices = numel(indices);

    % Require index magnitude to be smaller than the dimension length
    [maxMagnitude, loc] = max(abs(indices));
    if maxMagnitude >= obj.gridSize(d)
        indexMagnitudeTooLargeError(obj, d, maxMagnitude, loc, header);
    end

    % Check for size conflict with weights
    if obj.meanType(d)==2 && nIndices~=obj.meanSize(d)
        weightsSizeConflictError(obj, d, nIndices, header);
    end

    % Update size
    obj.meanSize(d) = nIndices;
    obj.meanIndices{d} = indices(:);
end

% Update type and omitnan
if obj.meanType(d)==0
    obj.meanType(d) = 1;
end
obj.omitnan(d) = omitnan;

end

% Error messages
function[] = existingTotalError(obj, d, header)
dim = obj.dims(d);
id = sprintf("%s:existingTotal", header);
ME = MException(id, ...
    ['You cannot call the "mean" command on the "%s" dimension because you are\n',...
    'already implementing a sum total over the dimension. If you want to use\n',...
    'the "mean" command for this dimension, you will first need to disable\n',...
    'the total by calling the "total" command with the "none" option for "%s".'],...
    dim, dim);
throwAsCaller(ME);
end
function[] = noMeanToUnweightError(obj, d, header)
dim = obj.dims(d);
id = sprintf('%s:noMeanToUnweight', header);
ME = MException(id, ...
    ['Cannot unweight the mean for the "%s" dimension because there is no\n',...
    'mean over the "%s" dimension.'], dim, dim);
throwAsCaller(ME);
end
function[] = meanIndicesNotAllowedError(obj, d, header)
dim = obj.dims(d);
id = sprintf('%s:meanIndicesNotAllowed', header);
ME = MException(id, ...
    ['You cannot provide mean indices for the "%s" dimension because it is\n',...
    'a state dimension.'], dim);
throwAsCaller(ME);
end
function[] = missingMeanIndicesError(obj, d, header)
dim = obj.dims(d);
id = sprintf('%s:missingMeanIndices', header);
ME = MException(id, ...
    ['You must provide mean indices for the "%s" dimension because it is\n',...
    'an ensemble dimension.'], dim);
throwAsCaller(ME);
end
function[] = weightsSizeConflictError(obj, d, nIndices, header)
dim = obj.dims(d);
nWeights = obj.meanSize(d);
id = sprintf('%s:weightsSizeConflict', header);
ME = MException(id, ...
    ['You previously specified a weighted mean for the "%s" dimension, and\n',...
    'the number of mean indices (%.f) does not match the number of weights (%.f).\n',...
    'Either change the number of mean indices, disable the weighted mean, or\n',...
    'update the weights.'], dim, nIndices, nWeights);
throwAsCaller(ME);
end
function[] = indexMagnitudeTooLargeError(obj, d, maxMagnitude, loc, header)

id = sprintf('%s:meanIndexMagnitudeTooLarge', header);
ME = MException(id, [...
    'Cannot take a mean over the "%s" dimension because the\n', ...
    'magnitude of mean index %.f (%.f) is not smaller than\n',...
    'the length of the dimension (%.f).'],...
    obj.dims(d), loc, maxMagnitude, obj.gridSize(d));
throwAsCaller(ME);
end


