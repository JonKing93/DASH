function[s] = sourcesForLoad(obj, loadIndices)
% loadIndices are in the order of the gridfile dimensions

% Preallocate 
nSource = obj.nSource;
nDims = numel(obj.dims);
inSourceDims = false(nSource, nDims);

% Attempt to broadcast the sources that hold indices for each dimension
for d = 1:nDims
    try
        insource =   loadIndices{d}>=obj.dimLimit(d,1,:) ...
                   & loadIndices{d}<=obj.dimLimit(d,2,:);
        inSourceDims(:,d) = any(insource, 1);
        continue
    catch
    end
    
    % But use an inner loop if broadcasting is too large
    for s = 1:nSource
        insource =   loadIndices{d}>=obj.dimLimit(d,1,s) ...
                   & loadIndices{d}<=obj.dimLimit(d,2,s);
        inSourceDims(s,d) = any(insource, 1);
    end
end

% Sources must have indices in all dimensions
s = all(inSourceDims, 2);
s = find(s);

end