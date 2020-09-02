function[subMembers] = removeOverlap(obj, subMembers, dims)
%% Updates a set of subscripted ensemble members to only include members
% non-overlapping data.
%
% subMembers = obj.removeOverlap(subMembers, dims)
%
% ----- Inputs -----
%
% subMembers: A set of subscripted ensemble member indices.
%
% dims: The dimension associated with each column of subMembers. A string
%    vector with one element per column in subMembers.
%
% ----- Outputs -----
%
% subMembers: The updated set of subscripted ensemble members. Any ensemble
%   ??????????????????????????????

% Get the dimension indices and sizes
d = obj.checkDimensions(dims);
nDims = numel(d);
nEns = size(subMembers, 1);

% Get add indices for all ensemble dimensions
nAdd = NaN(1, nDims);
addIndices = cell(1, nDims);
for k = 1:nDims
    addIndices{k} = obj.addIndices(d(k));
    nAdd(k) = numel(addIndices{k});
end

% Get subscript indices to propagate add indices over all ensemble dimensions
nEls = prod(nAdd);
addindexIndices = cell(1, nDims);
[addindexIndices{:}] = ind2sub( nAdd, (1:nEls)' );
addindexIndices = cell2mat(addindexIndices);

% Get subscripted add indices and subscripted reference indices
subAddIndices = NaN(nEls, nDims);
subRefIndices = NaN(nEns, nDims);
for k = 1:nDims
    subAddIndices(:,d(k)) = addIndices(addindexIndices(:,d(k)));
    subRefIndices(:,d(k)) = obj.indices{d(k)}(subMembers(:,k));
end

% Replicate the add indices over the reference indices and vice versa
subAddIndices = repmat(subAddIndices, [nEns, 1]);
subRefIndices = repmat( subRefIndices(:)', [nEls, 1]);
subRefIndices = reshape(subRefIndices, [nEns*nEls, nDims]);

% Add the subscripted reference indices to the subscripted add indices to
% get the load indices
loadIndices = subRefIndices + subAddIndices;

% Find duplicate load indices. Remove the associated ensemble members
[~, uniqueIndex] = unique(loadIndices, 'rows', 'stable');
overlap = 1:size(loadIndices,1);
overlap = overlap(~ismember(overlap, uniqueIndex));
badMember = unique(ceil(overlap/nEls));
subMembers(badMember, :) = [];

end