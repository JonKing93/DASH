function[] = matchMetadata(obj, d, metadata, grid)

% Get the variable's metadata. Sort the intersect
varMetadata = obj.getMetadata(d, grid);
[~, keep] = intersect(varMetadata, metadata, 'rows', 'stable');

% Update the reference indices and size
obj.indices{d} = obj.indices{d}(keep);
obj.ensSize(d) = numel(obj.indices{d});

% Update alternate metadata if it exists
if obj.metadataType(d)==1
    obj.metadata{d} = obj.metadata{d}(keep,:);
end

end
