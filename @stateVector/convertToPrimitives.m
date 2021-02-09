function[obj] = convertToPrimitives(obj)
%% Converts state vector variables to a structure array of primitives to
% facilitate fast saving.
%
% obj = obj.convertToPrimitives
%
% ----- Outputs -----
%
% obj: The updated stateVector object. The variables field has been
%    converted from a vector of svv to a structure of primitives.

% Initialize structure
s = struct;
nVars = numel(obj.variables);

% Collect strings: name, file
s.name = [obj.variables.name];
s.file = [obj.variables.file];
s.dims = strings(nVars, 1);
for v = 1:nVars
    s.dims(v) = dash.commaDelimitedDims(obj.variables(v).dims);
end

% Get dimension string and number of dimensions per variable
nDims = NaN(nVars, 1);
for v = 1:nVars
    nDims(v) = numel(obj.variables(v).dims);
end

% Collect vectors, store in a single vector
fields = stateVectorVariable.vectorFields;
nFields = numel(fields);
limits = dash.buildLimits(nDims*nFields);

% Collect the vectors for each variable
vectors = NaN(limits(end), 1);
for v = 1:nVars
    var = obj.variables(v);
    for f = 1:nFields
        index = limits(v,1) - 1 + (f-1)*nDims(v) + (1:nDims(v));
        vectors(index) = var.(fields{f});
    end
end
s.vectors = vectors;
s.limits = limits;

% Collect non-empty cells as named variables
fields = stateVectorVariable.cellFields;
nFields = numel(fields);
for v = 1:nVars
    var = obj.variables(v);
    for d = 1:nDims(v)
        dim = var.dims(d);
        for f = 1:nFields
            field = fields{f};

            % Only save if the cell has an entry
            if ~isempty(var.(field){d})
                name = sprintf('%s_%s_%s', field, dim, var.name);
                s.(name) = var.(field){d};
            end
        end
    end
end

% Collect indices
whichIndex = [NaN, 0, NaN, NaN]; % limits, var, dim
indices = [];
for v = 1:nVars
    var = obj.variables(v);
    for d = 1:nDims(v)
        if ~isequal(var.indices{d}', 1:var.gridSize(d))
            whichIndex = [whichIndex; whichIndex(end,2)+1, whichIndex(end,2)+numel(var.indices{d}), v, d]; %#ok<AGROW>
            indices = [indices; var.indices{d}]; %#ok<AGROW>
        end
    end
end
whichIndex(1,:) = [];
s.whichIndex = whichIndex;
s.indices = indices;

% Replace the variables with the structure
obj.variables = s;

end