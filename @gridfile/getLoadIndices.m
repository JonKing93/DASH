function[] = getLoadIndices(obj, userDimOrder, userIndices)

% Preallocate
nDims = numel(obj.dims);
loadIndices = cell(1, nDims);

% Copy user indices into the set of loadIndices
loadIndices(userDimOrder) = userIndices;

% Use all indices for empty dimensions
for d = 1:nDims
    if isempty(loadIndices{d})
        loadIndices{d} = 1:obj.size(d);
    end
    
    % Always use column vectors
    if isrow(loadIndices{d})
        loadIndices{d} = loadIndices{d}';
    end
end

end