function[svv] = buildFromPrimitives(svv, varName, file, dims, vectors, cellArgs, indices)
%% Builds a state vector variable from data stored in a primitive structure
%
% svv = svv.buildFromPrimitives(varName, file, dims, vectors, cellArgs, indices)
%
% ----- Inputs -----
%
% varName: The name of the variable. A string
%
% file: The filepath to the .grid file. A string
%
% dims: A string vector of dimension names
%
% vectors: Vector properties appended into a matrix
%
% cellArgs: Cell properties appended into a matrix
%
% indices: The indices for each dimension

% String fields
svv.name = varName;
svv.file = file;
svv.dims = dims;

% Vectors
fields = svv.vectorFields;
for f = 1:numel(fields)
    svv.(fields{f}) = vectors(f,:);
end

% Cells and indices
fields = svv.cellFields;
for f = 1:numel(fields)
    svv.(fields{f}) = cellArgs(f,:);
end
svv.indices = indices;

% Convert logicals
fields = {'isState','takeMean','omitnan','hasWeights','hasMetadata','convert'};
for f = 1:numel(fields)
    svv.(fields{f}) = logical(svv.(fields{f}));
end

end