function[] = rewriteMetadata( obj, dim, meta )
%% Rewrites the metadata in a .grid file along a specified dimension.
%
% obj.rewriteMetadata( dim, meta )
%
% ----- Inputs -----
%
% dim: The name of the dimension for which metadata is being rewritten. A
%    string.
%
% meta: The new metadata for the dimension. A numeric, logical,
%    char, string, cellstring, or datetime matrix. Each row is treated
%    as the metadata for one dimension element. Each row must be unique
%    and cannot contain NaN, Inf, or NaT elements. Cellstring metadata
%    will be converted into the "string" type.

% Update in case the file was changed.
obj.update;

% Error check
dim = dash.assertStrFlag(dim, "dim");
obj.checkAllowedDims(dim);
obj.checkMetadataField(meta, dim);

% Check the new metadata is the correct size
if size(meta,1) ~= size(obj.meta.(dim),1)
    error('The new %s metadata for .grid file %s must have %.f rows.', dim, obj.file, size(obj.meta.(dim),1));
end

% Update the metadata. Convert from cellstring. Update isdefined.
obj.updateMetadataField(dim, meta);

end