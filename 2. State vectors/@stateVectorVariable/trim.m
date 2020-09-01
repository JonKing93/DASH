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
    
    % Remove reference indices that would exceed the dimension length
    maxAdd = max(obj.seqIndices{d(k)}) + max(obj.meanIndices{d(k)});
    remove = obj.indices{d(k)} + maxAdd > dimLength;
    obj.indices{d(k)}(remove) = [];
    
    % Remove reference indices that would precede the dimension
    maxSubtract = min(obj.seqIndices{d(k)}) + min(obj.meanIndices{d(k)});
    remove = obj.indices{d(k)} + maxSubtract < 1;
    obj.indices{d(k)}(remove) = [];
end

end