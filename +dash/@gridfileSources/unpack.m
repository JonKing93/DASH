function[dims, size, mergedDims, mergedSize, mergeMap] = unpack(obj, s)

dims = strsplit(obj.dims(s), ',');
size = strsplit(obj.size(s), ',');
size = str2double(size);
mergedDims = strsplit(obj.mergedDims(s), ',');
mergedSize = strsplit(obj.mergedSize(s), ',');
mergedSize = str2double(mergedSize);
mergeMap = strsplit(obj.mergeMap(s), ',');
mergeMap = str2double(mergeMap);

end