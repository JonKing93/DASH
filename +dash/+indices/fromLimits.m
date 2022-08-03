function[indices] = fromLimits(limits)
%% dash.indices.fromLimits  Return all indices within sets of index limits
% ----------
%   indices = dash.indices.fromLimits(limits)
%   Returns the collections of indices that fall within given sets of index
%   limits.
% ----------
%   Inputs:
%       limits (matrix, positive integers [nSets x 2]): The index limits of
%           sets of elements within an overall collection.
%
%   Outputs:
%       indices (cell vector [nSets] {vector, linear indices}): The full
%           set of indices within each set of limits.
%
% <a href="matlab:dash.doc('dash.indices.fromLimits')">Documentation Page</a>

% Preallocate
nDims = size(limits,1);
indices = cell(1, nDims);

% Get indices for each dimension
for d = 1:nDims
    indices{d} = (limits(d,1):limits(d,2))';
end

end