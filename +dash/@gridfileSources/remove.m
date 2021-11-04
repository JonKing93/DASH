function[obj] = remove(obj, s)

% Use linear indices
if islogical(s)
    s = find(s);
end

% Remove indexed import options
remove = find(ismember(obj.importOptionSource, s));
obj.importOptions(remove) = [];
obj.importOptionSource(remove) = [];

% Remove everything else
obj.source(s) = [];
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