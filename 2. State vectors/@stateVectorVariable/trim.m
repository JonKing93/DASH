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
    
    % Remove reference indices that would exceed the dimension length
    remove = (obj.indices{d(k)} + maxAdd) > dimLength;
    obj.indices{d(k)}(remove) = [];
    
    % Remove reference indices that would precede the dimension
    remove = (obj.indices{d(k)} + maxSubtract) < 1;
    obj.indices{d(k)}(remove) = [];
    
    % Update the size of the ensemble dimension
    obj.ensSize(d(k)) = numel(obj.indices{d(k)});
end

end