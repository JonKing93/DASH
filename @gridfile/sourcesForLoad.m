function[s] = sourcesForLoad(obj, loadIndices)
%% gridfile.sourcesForLoad  Return the indices of data sources needed to load requested data
% ----------
%   s = <strong>obj.sourcesForLoad</strong>(loadIndices)
%   Returns the indices of the gridfile data sources that are required to
%   implement a load operation.
% ----------
%   Inputs:
%       loadIndices (cell vector [nDims] {linear indices}): The indices of
%           data elements that are requested for a load operation. Should
%           have one element per dimension in the gridfile. The order of
%           dimensions should match the order of dimensions in the
%           gridfile.
%
%   Outputs:
%       s (vector, linear indices): The indices of data sources that are
%           required in order to load the requested data.
%
% <a href="matlab:dash.doc('gridfile.sourcesForLoad')">Documentation Page</a>

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