function[] = updateMetadataField( obj, dim, meta )
d = strcmp(dim, obj.dims);
[obj.meta.(dim), obj.gridSize(d)] = gridfile.processMetadata(meta);
obj.isdefined(d) = true;
obj.save;
end