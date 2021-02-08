function[svv] = buildFromPrimitives(svv, varName, file, dims, vectors, cellArgs, indices)
%% Builds a state vector variable from data stored in a primitive structure


svv.name = varName;
svv.file = file;
svv.dims = dims;

fields = svv.vectorFields;
for f = 1:numel(fields)
    svv.(fields{f}) = vectors(f,:);
end

fields = svv.cellFields;
for f = 1:numel(fields)
    svv.(fields{f}) = cellArgs(f,:);
end

svv.indices = indices;

end

