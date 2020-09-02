function[meta] = matchingMetadata(obj, meta, grid, dim)
%% Return metadata that matches a second set of metadata at the indices
% along a dimension.
%
% meta = obj.matchingMetadata(meta, grid, dim)
%
% ----- Inputs -----
%
% meta: The second set of metadata
%
% grid: The gridfile object associated with the variable.
%
% dim: The name of the dimension. A string
%
% ----- Outputs -----
%
% meta: The metadata intersect

% Get the variable's metadata
varMeta = obj.dimMetadata(grid, dim);

% Get the metadata intersect
try
    meta = intersect(meta, varMeta, 'rows', 'stable');
catch
    meta = [];
end

end