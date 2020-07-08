function[] = updateMetadataField( obj, dim, meta )
d = strcmp(dim, obj.dims);
[obj.meta.(dim), obj.size(d)] = gridfile.processMetadata(meta);
obj.isdefined(d) = true;
obj.save;
end