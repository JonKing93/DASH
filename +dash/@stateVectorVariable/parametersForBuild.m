function[parameters] = parametersForBuild(obj)

% Get the size of a loaded ensemble members
meanSize = obj.meanSize;
meanSize(isnan(meanSize)) = 1;
loadedSize = obj.stateSize .* meanSize;

% Record location of dimensions for means
nDims = numel(obj.dims);
meanDims = 1:nDims;

% Adjust size and mean dimensions for multiple sequence elements
for d = nDims:-1:1
    if ~obj.isState(d) && obj.stateSize(d)>1
        loadedSize = [loadedSize(1:d-1), obj.meanSize(d), obj.stateSize(d), loadedSize(d+1:end)];
        meanDims(d+1:end) = meanDims(d+1:end)+1;
    end
end

% Organize output
parameters = struct('loadedSize', loadedSize, 'meanDims', meanDims);

end