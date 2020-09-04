function[obj] = trim(obj)
%% Adjusts reference indices to only allow complete sequences and means.
%
% obj = obj.trim
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable

% Get the length of each ensemble dimension in the .grid file
d = find(~obj.isState);
for k = 1:numel(d)
    dimLength = obj.gridSize(d(k));
    
    % Get the maximum and minimum add indices
    addIndices = obj.addIndices(d(k));
    maxAdd = max(addIndices);
    maxSubtract = min(addIndices);
    
    % Find reference indices that would exceed or precede the dimension
    tooLong = (obj.indices{d(k)} + maxAdd) > dimLength;
    tooShort = (obj.indices{d(k)} + maxSubtract) < 1;
    remove = tooLong | tooShort;
    
    % Remove the indices. Update metadata and size
    obj.indices{d(k)}(remove) = [];
    if obj.hasMetadata(d(k))
        obj.metadata{d(k)}(remove,:) = [];
    end
    obj.ensSize(d(k)) = numel(obj.indices{d(k)});
end

end