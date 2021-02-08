function[sv] = revertFromPrimitives(sv)
%% Converts a stateVectorVariable primitive structure back to an object array

% Extract the variable structure and clear the property
s = sv.variables;
sv.variables = [];

% Settings
cellFields = stateVectorVariable.cellFields;
g = strcmp('gridSize', stateVectorVariable.vectorFields);
nFields = numel(cellFields);
sfields = fields(s);

% Get the fields required to build each variable
nVars = numel(s.name);
for v = 1:nVars
    varName = s.name(v);
    file = s.file(v);
    dims = textscan(char(s.dims(v)), '%s', 'Delimiter', ',');
    dims = string(dims{:}');
    
    % Vectors
    limit = s.limits(v,:);
    nDims = numel(dims);
    vectors = s.vectors(limit(1):limit(end));
    vectors = reshape(vectors, [nDims, 10])';
    
    % Collect cells
    cellArgs = repmat(cell(1,nDims), [nFields, 1]);
    for f = 1:nFields
        for d = 1:nDims
            name = sprintf('%s_%s_%s', cellFields{f}, dims(d), varName);
            if any(strcmp(name, sfields))
                cellArgs{f,d} = s.(name);
            end
        end
    end
    
    % Initialize indices
    indices = cell(1, nDims);
    for d = 1:nDims
        indices{d} = (1:vectors(g,d))';
    end
    
    % Collect user indices
    var = s.whichIndex(:,3)==v;
    limit = s.whichIndex(var, 1:2);
    d = s.whichIndex(var, 4);
    for k = 1:numel(d)
        use = limit(k,1):limit(k,end);
        indices{d(k)} = s.indices(use);
    end
    
    % Add the new variable
    svv = stateVectorVariable;
    svv = svv.buildFromPrimitives(varName, file, dims, vectors, cellArgs, indices);
    sv.variables = [sv.variables; svv];
end

end


