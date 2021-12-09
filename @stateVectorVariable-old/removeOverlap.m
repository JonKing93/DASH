function[subMembers] = removeOverlap(obj, subMembers, dims)
%% Updates a set of subscripted ensemble members to only include members
% with non-overlapping data.
%
% subMembers = obj.removeOverlap(subMembers, dims)
% Removes any ensemble members with overlapping data from a set of
% subscripted ensemble members.
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
%    member with overlapping data is deleted from the array

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
    subAddIndices(:,k) = addIndices{k}(addindexIndices(:,k));
    subRefIndices(:,k) = obj.indices{d(k)}(subMembers(:,k));
end

% Replicate the add indices over the reference indices and vice versa.
subAddIndices = repmat(subAddIndices, [nEns, 1]);
subRefIndices = repmat( subRefIndices(:)', [nEls, 1]);
subRefIndices = reshape(subRefIndices, [nEns*nEls, nDims]);

% Find overlapping data and iteratively remove ensemble members until no
% overlap occurs
overlap = findOverlap( subRefIndices, subAddIndices, nEls );
while ~isempty(overlap)
    r = ceil(overlap(1)/nEls);
    remove = (r-1)*nEls + (1:nEls);
    subRefIndices(remove, :) = [];
    subAddIndices(remove, :) = [];
    subMembers(r, :) = [];
    overlap = findOverlap(subRefIndices, subAddIndices, nEls);
end

end

% DRY helper method
function[overlap] = findOverlap(subRefIndices, subAddIndices, nEls)

% Get the load indices and their associated ensemble member
loadIndices = subRefIndices + subAddIndices;
index = 1:size(loadIndices,1);
member = ceil(index/nEls);

% Find all load indices that are not the first occurence
[~, first, map] = unique(loadIndices, 'rows', 'stable');
overlap = index(~ismember(index, first));

% Allow overlap in the same ensemble member as the first occurrence
overlapMember = member(overlap);
firstMember = member(first(map(overlap)));
overlap(overlapMember==firstMember) = [];

end