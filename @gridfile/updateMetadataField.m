function[] = updateMetadataField( obj, dim, meta )
%% Updates the a metadata field in a .grid file.
%
% obj.updateMetadataField(dim, meta);
%
% ----- Inputs -----
%
% dim: The name of the dimension for which metadata is being updated
%
% meta: The new metadata field

d = strcmp(dim, obj.dims);
obj.meta.(dim) = meta;
obj.size(d) = size(meta, 1);
obj.isdefined(d) = true;
obj.save;

end