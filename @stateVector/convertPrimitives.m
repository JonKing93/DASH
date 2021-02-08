function[obj] = convertPrimitives(obj)
%% Converts state vector variables to a structure array

% Initialize structure
s = struct;
nVars = numel(obj.variables);

% Collect strings: name, file, dims
s.name = [obj.variables.name];
s.file = [obj.variables.file];
s.dims = strings(nVars, 1);
for v = 1:nVars
    s.dims(v) = dash.commaDelimitedDims(obj.variables(v).dims);
end

% Collect vectors, store in a single vector and separate variables by
% dimension size
nDims = NaN(nVars, 1);
for v = 1:nVars
    nDims(v) = numel(obj.variables(v).dims);
end
vectorFields = {'gridSize','stateSize','ensSize','isState','takeMean','meanSize',...
                'omitnan','hasWeights','hasMetadata','convert'};
nFields = numel(vectorFields);
limits = dash.buildLimits(nDims*nFields);
vectors = NaN(limits(end), 1);
for v = 1:nVars
    var = obj.variables(v);
    vectors(limits(v,1):limits(v,2)) = ...
       [var.gridSize, var.stateSize, var.ensSize, var.isState, var.takeMean, ...
        var.meanSize, var.omitnan, var.hasWeights, var.hasMetadata, var.convert];
end
s.vectors = vectors;
s.limits = limits;

% Collect cells
fields = {'seqIndices','seqMetadata','mean_Indices','weightCell','metadata','convertFunction','convertArgs'};
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