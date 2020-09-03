function[obj] = matchIndices(obj, meta, grid, dim)
%% Updates indices along an ensemble dimension to match metadata.
%
% obj = obj.matchIndices(meta, grid, dim)
%
% ----- Inputs -----
%
% meta: The metadata to match
%
% grid: The gridfile object associated with the stateVectorVariable
%
% dim: The name of the dimension. A string
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable object.

% Get the variable's metadata. Find the metadata intersect
varMeta = obj.dimMetadata(grid, dim);
[~, keep] = intersect(varMeta, meta, 'rows', 'stable');

% Update the reference indices
d = obj.checkDimensions(dim);
obj.indices{d} = obj.indices{d}(keep);

end