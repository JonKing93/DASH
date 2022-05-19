function[subMembers] = removeOverlap(obj, dims, subMembers)
%% dash.stateVectorVariable.removeOverlap  Remove ensemble members that overlap previous members
% ----------
%   subMembers = <strong>obj.removeOverlap</strong>(dims, subMembers)
%   Takes a set of dimensionally-subscripted ensemble members and removes
%   any members whose metadata overlaps metadata in previous ensemble
%   members. Each ensemble member is a row of subMembers. Removes
%   overlapping members from the end of subMembers, so new ensemble members
%   should be located at the end of subMembers in order to preserve
%   previously saved ensemble members.
%
%   **Note**: This method can only be called after the variable has been
%   finalized.
% ----------
%   Inputs:
%       dims (vector, linear indices [nEnsDims]): The dimension indices for
%           the variable that correspond to the columns of subMembers.
%       subMembers (matrix, linear indices [nInitial x nEnsDims]): A set of
%           dimensionally-subscripted ensemble members for the variable.
%
%   Outputs:
%       subMembers (matrix, linear indices [nFinal x nEnsDims]): An updated
%           set of dimensionally-subscripted ensemble members. Members with
%           metadata that overlaps previous members have been removed.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.removeOverlap')">Documentation Page</a>

% Get sizes
[nMembers, nEnsDims] = size(subMembers);

% Get the add indices to add to the reference element of each ensemble dimension
nAdd = NaN(1, nEnsDims);
addIndices = cell(1, nEnsDims);
for k = 1:nEnsDims
    d = dims(k);
    addIndices{k} = obj.addIndices(d);
    nAdd(k) = numel(addIndices{k});
end

% Get the total number of gridfile elements loaded over all the ensemble
% dimensions. This multiplies the number of add indices in each dimension
% across all the ensemble dimensions
nElements = prod(nAdd);

% We're going to dimensionally-subscript the entire set of add indices.
% Get indices that indicate which add index is used for each element of the
% complete set of loaded indices.
addindexIndices = cell(1, nEnsDims);
[addindexIndices{:}] = ind2sub(nAdd, (1:nElements)');
addindexIndices = cell2mat(addindexIndices);

% Dimensionally-subscript the add indices and reference indices across all
% the ensemble dimensions
subAddIndices = NaN(nElements, nEnsDims);
subRefIndices = NaN(nMembers, nEnsDims);
for k = 1:nEnsDims
    d = dims(k);
    subAddIndices(:,k) = addIndices{k}(addindexIndices(:,k));
    subRefIndices(:,k) = obj.indices{d}(subMembers(:,k));
end

% Replicate the add indices over the reference indices and vice versa
subAddIndices = repmat(subAddIndices, [nMembers 1]);
subRefIndices = subRefIndices(:)';
subRefIndices = repmat(subRefIndices, [nElements 1]);
subRefIndices = reshape(subRefIndices, [nMembers*nElements, nEnsDims]);

% Find overlapping data and iteratively remove members until no overlap occurs
overlap = findOverlap(subRefIndices, subAddIndices, nElements);
while ~isempty(overlap)

    % Determine the ensemble member associated with the first overlapping
    % element and get all associated loaded indices
    badMember = ceil(overlap(1) / nElements);
    remove = (badMember-1)*nElements + (1:nElements);
    
    % Remove the bad ensemble member, check if overlap persists
    subRefIndices(remove,:) = [];
    subAddIndices(remove,:) = [];
    subMembers(badMember, :) = [];
    overlap = findOverlap(subRefIndices, subAddIndices, nElements);
end

end

% Utilty function
function[overlap] = findOverlap(subRefIndices, subAddIndices, nElements)

% Get the gridfile indices of loaded elements, and the ensemble member associated
% with each loaded element
loadIndices = subRefIndices + subAddIndices;
index = 1:size(loadIndices,1);
member = ceil(index / nElements);

% Find all load indices repeated after the first occurence
[~, first, map] = unique(loadIndices, 'rows', 'stable');
overlap = index(~ismember(index, first));

% Allow overlap within the same ensemble member as the first occurrence
overlapMember = member(overlap);
firstMember = member(first(map(overlap)));
overlap(overlapMember==firstMember) = [];

end