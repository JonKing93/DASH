function[settings] = loadSettings(obj, subDims)
%% Converts user options to values used to design a load operation

% NaN flag for each dimension
nDims = numel(obj.dims);
nanflag = repmat("includenan", [1 nDims]);
nanflag(obj.omitnan) = "omitnan";

% Size of loaded data
siz = obj.stateSize .* obj.meanSize;

% Track the location of dimensions for taking means. Get the index of the
% subMember dimensions within the stateVectorVariable
meanDims = 1:nDims;
d = obj.checkDimensions(subDims);

% Propagate mean indices over sequences to get add indices
addIndices = cell(1, numel(d));
for k = 1:numel(d)
    addIndices{k} = obj.addIndices(d(k));
    
    % If the ensemble dimension has a sequence, split the mean elements
    % from the sequence elements. Update the size of the loaded data, and
    % the location of the mean dimensions.
    if obj.stateSize(d(k))>1
        siz = [siz(1:d(k)-1), obj.meanSize(d(k)), obj.stateSize(d(k)), siz(d(k)+1:end)];
        meanDims(d(k)+1:end) = meanDims(d(k)+1:end)+1;
    end
end

% Initialize load indices for the state dimensions
indices = cell(1, nDims);
indices(obj.isState) = obj.indices(obj.isState);

% Collect everything in a structure
settings = struct('siz', siz, 'd', d, 'meanDims', meanDims, 'nanflag', nanflag);
settings.indices = indices;
settings.addIndices = addIndices;

end