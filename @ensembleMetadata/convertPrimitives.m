function[s] = convertPrimitives(meta)


s = struct();
nVars = numel(meta.variableNames);

% Get any directly copyable fields
names = {'name','variableNames','varLimit','nEls','nEns'};
for n = 1:numel(names)
    s.(names{n}) = meta.(names{n});
end

% Convert dims to comma strings
dims = strings(nVars, 1);
nDims = NaN(nVars, 1);
for v = 1:nVars
    dims(v) = dash.commaDelimitedDims(meta.dims{v});
    nDims(v) = numel(meta.dims{v});
end
s.dims = dims;

% Dimension vectors
s.limits = dash.buildLimits(nDims);
names = {'stateSize','isState','meanSize'};
for n = 1:numel(names)
    name = names{n};
    s.(name) = [];
    for v = 1:nVars
        s.(name) = [s.(name), meta.(name){v}];
    end
end

% Metadata
vars = string(fields(meta.metadata));
dimType = ["state", "ensemble"];
saveType = [];
for v = 1:nVars
    for t = 1:2
        varMeta = meta.metadata.(vars(v)).(dimType(t));
        dims = string(fields(varMeta));
        for d = 1:numel(dims)
            dimMeta = varMeta.(dims(d));
            
            % Determine the data type of the metadata
            type = string(class(dimMeta));
            if isempty(dimMeta)
                type = 'empty';
            end
            
            % Collect any organizing data. Convert the metadata to a column
            % vector
            whichName = sprintf('which_%s', type);
            nCols = size(dimMeta, 2);
            dimMeta = dimMeta(:);
            
            % Initialize the structure fields if this is the first instance
            % of the data type
            if ~any(strcmp(type, saveType))
                s.(type) = [];
                s.(whichName) = [];
                saveType = [saveType; type];
                last = 0;
                
            % Otherwise, append to existing data
            else
                last = s.(whichName)(end,2);
            end
            
            % Add the metadata to the structure
            if strcmp(type, 'empty')
                s.(whichName) = [s.(whichName); v, d, t];
            else
                s.(type) = [s.(type); dimMeta];
                s.(whichName) = [s.(whichName); last+1, last+numel(dimMeta), v, d, t, nCols];
            end
        end
    end
end           
            
end       