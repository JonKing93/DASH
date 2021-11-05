function[obj] = remove(obj, s)

% Remove indexed import options
remove = find(ismember(obj.importOptionSource, s));
obj.importOptions(remove) = [];
obj.importOptionSource(remove) = [];

% Remove everything else
obj.type(s) = [];
obj.source(s) = [];
obj.relativePath(s) = [];
obj.dataType(s) = [];
obj.var(s) = [];
obj.dims(s) = [];
obj.size(s) = [];
obj.mergedDims(s) = [];
obj.mergedSize(s) = [];
obj.fill(s) = [];
obj.range(s,:) = [];
obj.transform(s) = [];
obj.transform_params(s,:) = [];

end