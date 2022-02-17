function[obj] = deserialize(s)
%% dash.stateVectorVariable.deserialize  Rebuild a vector of stateVectorVariable objects from a serialized struct
% ----------
%   obj = dash.stateVectorVariable.deserialize(s)
%   Rebuilds a vector of stateVectorVariable objects from a serialized
%   struct. This method DOES NOT error check the deserialized struct.
% ----------
%   Inputs:
%       s (scalar struct): A serialized struct for a 

% Get the number of variables and dimensions. Initialize the vector
nVars = numel(s.dims);
nDims = s.nDims;
obj = dash.stateVectorVariable;
obj = repmat(obj, nVars, 1);


%% String delimited properties

numericFields = ["gridSize","stateSize","ensSize","meanSize","meanType","metadataType"];
logicalFields = ["isState","hasSequence","omitnan"];

% Delimit fields, restore type
obj = delimitConvert(obj, s, nVars, numericFields, {@str2double});
obj = delimitConvert(obj, s, nVars, logicalFields, {@str2double, @logical});
obj = delimitConvert(obj, s, nVars, "convertFunction", {@cellstr});
obj = delimitConvert(obj, s, nVars, "dims", {});

% Restore function handles
for v = 1:nVars
    for d = 1:nDims(v)
        if ~isempty(obj(v).convertFunction{d})
            obj(v).convertFunction{d} = str2func(obj(v).convertFunction{d});
        end
    end
end


%% Cell vectors

obj = extractVectors(obj, s, nVars, 'indices', s.nIndices);
obj = extractVectors(obj, s, nVars, 'meanIndices', s.nMean);
obj = extractVectors(obj, s, nVars, 'sequenceIndices', s.nSequence);
obj = extractVectors(obj, s, nVars, 'weights', s.nWeights);


%% Cells with unpredictable contents

% Preallocate cells
for v = 1:nVars
    obj(v).sequenceMetadata = cell(1, nDims(v));
    obj(v).metadata_ = cell(1, nDims(v));
    obj(v).convertArgs = cell(1, nDims(v));
end

% Fill cells with saved elements
obj = fillCells(obj, s, 'sequenceMetadata', s.vdSequenceMetadata);
obj = fillCells(obj, s, 'metadata_', s.vdMetadata);
obj = fillCellVectors(obj, s, 'convertArgs', s.vdConvertArgs);

end

% Utility methods
function[str] = delimit(str)
str = strsplit(str, ',', 'CollapseDelimiters', false);
end
function[obj] = delimitConvert(obj, s, nVars, fields, convert)

nConvert = numel(convert);
for f = 1:numel(fields)
    field = fields(f);

    for v = 1:nVars
        values = s.(field)(v);
        values = delimit(values);
        for k = 1:nConvert
            values = convert{k}(values);
        end
        obj(v).(field) = values;
    end
end

end
function[obj] = extractVectors(obj, s, nVars, field, counts)

last = 0;

% Get the number of elements for each variable
for v = 1:nVars
    dimCounts = strsplit(counts(v), ',');
    dimCounts = str2double(dimCounts);
    nElements = sum(dimCounts);

    % Extract elements
    k = last + (1:nElements);
    values = s.(field)(k);
    if isempty(values)
        values = NaN(0,1);
    end

    % Split across dimensions
    values = mat2cell(values, dimCounts, 1)';
    obj(v).(field) = values;

    % Update location
    last = last + nElements;
end

end
function[obj] = fillCells(obj, s, field, vdIndices)

for k = 1:size(vdIndices,1)
    v = vdIndices(k,1);
    d = vdIndices(k,2);
    obj(v).(field)(d) = s.(field)(k);
end

end
function[obj] = fillCellVectors(obj, s, field, vdIndices)

afterEnd = size(vdIndices,1);
[vdIndices, firstIndex] = unique(vdIndices, 'rows', 'stable');
nElements = diff([firstIndex;afterEnd]);

previous = 0;
for k = 1:size(vdIndices,1)
    v = vdIndices(k,1);
    d = vdIndices(k,2);

    rows = previous + (1:nElements);
    obj(v).(field){d} = s.(field)(rows)';
end

end