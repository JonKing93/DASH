function[obj] = mean(obj, d, indices, omitnan, header)

%% Discard settings

% Fully disable mean
if isequal(indices, "none")
    obj.meanType(d) = 0;
    obj.meanSize(d) = NaN;
    obj.meanIndices(d) = {[]};
    obj.omitnan(d) = false;
    obj.weights(d) = {[]};
    return;

% Disable weighted mean. Check dimensions are all taking a mean
elseif isequal(indices, "unweighted")
    noMean = obj.meanType(d)==0;
    if any(noMean)
        noMeanToUnweightError(dims, noMean, header);
    end

    % Remove weights
    obj.meanType(d) = 1;
    obj.weights(d) = {[]};
    return;
end

%% Set a mean

% Cycle through dimensions. Update state vs ensemble
for k = 1:numel(dims)
    d = dims(k);

    % Process state vs ensemble dimensions
    inputs = {obj, d, indices{k}, header};
    if obj.isState(d)
        obj = stateDimension(inputs{:});
    else
        obj = ensembleDimension(inputs{:});
    end

    % Update type and omitnan
    if obj.meanType(d)==0
        obj.meanType(d) = 1;
    end
    obj.omitnan(d) = omitnan(k);
end

end

% Utility functions
function[obj] = stateDimension(obj, d, indices, header)

% Prohibit indices
if ~isempty(indices)
    meanIndicesNotAllowedError(d, header);
end

% Update
if obj.meanType(d)==0
    obj.meanSize(d) = obj.stateSize(d);
    obj.stateSize(d) = 1;
end
obj.omitnan(d) = omitnan;

end
function[obj] = ensembleDimension(obj, d, indices, header)

% Require indices
if isempty(indices)
    missingMeanIndicesError(d, header);
end
nIndices = numel(indices);

% Check for size conflict with weights
if obj.meanType(d)==2 && nIndices~=obj.meanSize(d)
    weightsSizeConflictError(d, nIndices, header);
end

% Update
if obj.meanType(d)==0
    obj.meanType(d) = 1;
end
obj.meanSize(d) = nIndices;
obj.meanIndices{d} = indices(:);

end

% Error messages
function[] = noMeanToUnweightError(d, noMean, header)
bad = find(noMean, 1);
dim = obj.dims(d(bad));
id = sprintf('%s:noMeanToUnweight', header);
ME = MException(id, ...
    ['Cannot unweight the mean for the "%s" dimension because there is no\n',...
    'mean over the "%s" dimension.'], dim, dim);
throwAsCaller(ME);
end
function[] = meanIndicesNotAllowedError(d, header)
dim = obj.dims(d);
id = sprintf('%s:meanIndicesNotAllowed', header);
ME = MException(id, ...
    ['You cannot provide mean indices for the "%s" dimension because it is\n',...
    'a state dimension.'], dim);
throwAsCaller(ME);
end
function[] = missingMeanIndicesError(d, header)
dim = obj.dims(d);
id = sprintf('%s:missingMeanIndices', header);
ME = MException(id, ...
    ['You must provide mean indices for the "%s" dimension because it is\n',...
    'an ensemble dimension.'], dim);
throwAsCaller(ME);
end
function[] = weightsSizeConflictError(d, nIndices, header)
dim = obj.dims(d);
nWeights = obj.meanSize(d);
id = sprintf('%s:weightsSizeConflict', header);
ME = MException(id, ...
    ['You previously specified a weighted mean for the "%s" dimension, and\n',...
    'the number of mean indices (%.f) does not match the number of weights (%.f).\n',...
    'Either change the number of mean indices, disable the weighted mean, or\n',...
    'updated the weights.'], dim, nIndices, nWeights);
throwAsCaller(ME);
end



