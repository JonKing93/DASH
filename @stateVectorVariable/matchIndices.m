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
if dash.bothNaN(meta, varMeta)
    keep = 1;
else
    [~, keep] = intersect(varMeta, meta, 'rows', 'stable');
end

% Update the reference indices. Update metadata and size
d = obj.checkDimensions(dim);
obj.indices{d} = obj.indices{d}(keep);
if obj.hasMetadata(d)
    obj.metadata{d} = obj.metadata{d}(keep, :);
end
obj.ensSize(d) = numel(obj.indices{d});

end