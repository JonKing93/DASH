function[meta] = buildFromPrimitives(meta, s)
%% Builds ensembleMetadata from a primitive structure

% Set any copyable fields
names = meta.copyableFields;
for f = 1:numel(names)
    meta.(names{f}) = s.(names{f});
end

% Dims
nVars = numel(s.variableNames);
nDims = NaN(nVars, 1);
meta.dims = cell(nVars, 1);
for v = 1:nVars
    dims = textscan(char(s.dims(v)), '%s', 'Delimiter', ',');
    meta.dims{v} = string(dims{:}');
    nDims(v) = numel(meta.dims{v});
end

% Dimension vectors
meta.stateSize = cell(nVars, 1);
meta.isState = cell(nVars, 1);
meta.meanSize = cell(nVars, 1);

for v = 1:nVars
    index = s.limits(v,1):s.limits(v,end);
    meta.stateSize{v} = s.stateSize(index);
    meta.meanSize{v} = s.meanSize(index);
    meta.isState{v} = logical(s.isState(index));
end

% Get data types
names = fields(s);
types = cell(0,1);
for f = 1:numel(names)
    if length(names{f})>4 && strcmp(names{f}(1:5), 'which')
        newType = names{f}(7:end);
        types = [types; newType]; %#ok<AGROW>
    end
end

% Build the metadata for each data type
stateType = ["state","ensemble"];
for t = 1:numel(types)
    name = sprintf('which_%s', types{t});
    whichArg = s.(name);
    
    % Build the metadata from each row
    for r = 1:size(whichArg,1)
        if strcmp(types{t}, 'empty')
            data = [];
            k = 1;
        else
            data = s.(types{t})(whichArg(r,1):whichArg(r,2));
            nCols = whichArg(r,6);
            nDepth = whichArg(r,7);
            nRows = numel(data)/(nCols*nDepth);
            data = reshape(data, [nRows, nCols, nDepth]);
            k = 3;
        end
        
        v = whichArg(r,k);
        varName = meta.variableNames(v);
        dimName = meta.dims{v}(whichArg(r,k+1));
        stateName = stateType(whichArg(r, k+2));
        meta.metadata.(varName).(stateName).(dimName) = data;
    end
end

% Order the metadata fields
for v = 1:nVars
    varName = meta.variableNames(v);
    dims = meta.dims{v};
    meta.metadata.(varName).state = orderfields(meta.metadata.(varName).state, dims);
    meta.metadata.(varName).ensemble = orderfields(meta.metadata.(varName).ensemble, dims);
end


end     