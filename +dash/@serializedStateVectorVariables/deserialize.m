function[svv] = deserialize(obj)
%% dash.serializedStateVectorVariable.deserialize  Rebuild a serialized vector of stateVectorVariable objects
% ----------
%   svv = <strong>obj.deserialize</strong>
%   Rebuilds a vector of stateVectorVariable objects from a serialized
%   object.
% ----------
%   Outputs:
%       svv (vector, stateVectorVariable objects): The deserialized vector
%           of stateVectorVariable objects
%
% <a href="matlab:dash.doc('dash.serializedStateVectorVariable.deserialize')">Documentation Page</a>


% Get the number of variables and dimensions. Initialize the vector
nVars = numel(obj.dims);
nDims = obj.nDims;
svv = dash.stateVectorVariable;
svv = repmat(svv, nVars, 1);


%% String delimited properties

numericFields = ["gridSize","stateSize","ensSize","meanSize","meanType","metadataType"];
logicalFields = ["isState","hasSequence","omitnan"];

% Delimit fields, restore type
svv = delimitConvert(obj, svv, nVars, numericFields, {@str2double});
svv = delimitConvert(obj, svv, nVars, logicalFields, {@str2double, @logical});
svv = delimitConvert(obj, svv, nVars, "convertFunction", {@cellstr});
svv = delimitConvert(obj, svv, nVars, "dims", {});

% Restore function handles
for v = 1:nVars
    for d = 1:nDims(v)
        if ~isempty(svv(v).convertFunction{d})
            svv(v).convertFunction{d} = str2func(svv(v).convertFunction{d});
        end
    end
end


%% Cell vectors

svv = extractVectors(obj, svv, nVars, 'indices', obj.nIndices);
svv = extractVectors(obj, svv, nVars, 'meanIndices', obj.nMean);
svv = extractVectors(obj, svv, nVars, 'sequenceIndices', obj.nSequence);
svv = extractVectors(obj, svv, nVars, 'weights', obj.nWeights);


%% Cells with unpredictable contents

% Preallocate cells
for v = 1:nVars
    svv(v).sequenceMetadata = cell(1, nDims(v));
    svv(v).metadata_ = cell(1, nDims(v));
    svv(v).convertArgs = cell(1, nDims(v));
end

% Fill cells with saved elements
svv = fillCells(obj, svv, 'sequenceMetadata', obj.vdSequenceMetadata);
svv = fillCells(obj, svv, 'metadata_', obj.vdMetadata);
svv = fillCellVectors(obj, svv, 'convertArgs', obj.vdConvertArgs);

end

% Utility methods
function[str] = delimit(str)
str = strsplit(str, ',', 'CollapseDelimiters', false);
end
function[svv] = delimitConvert(obj, svv, nVars, fields, convert)

nConvert = numel(convert);
for f = 1:numel(fields)
    field = fields(f);

    for v = 1:nVars
        values = obj.(field)(v);
        values = delimit(values);
        for k = 1:nConvert
            values = convert{k}(values);
        end
        svv(v).(field) = values;
    end
end

end
function[svv] = extractVectors(obj, svv, nVars, field, counts)

last = 0;

% Get the number of elements for each variable
for v = 1:nVars
    dimCounts = strsplit(counts(v), ',');
    dimCounts = str2double(dimCounts);
    nElements = sum(dimCounts);

    % Extract elements
    k = last + (1:nElements);
    values = obj.(field)(k);
    if isempty(values)
        values = NaN(0,1);
    end

    % Split across dimensions
    values = mat2cell(values, dimCounts, 1)';
    svv(v).(field) = values;

    % Update location
    last = last + nElements;
end

end
function[svv] = fillCells(obj, svv, field, vdIndices)

for k = 1:size(vdIndices,1)
    v = vdIndices(k,1);
    d = vdIndices(k,2);
    svv(v).(field)(d) = obj.(field)(k);
end

end
function[svv] = fillCellVectors(obj, svv, field, vdIndices)

afterEnd = size(vdIndices,1);
[vdIndices, firstIndex] = unique(vdIndices, 'rows', 'stable');
nElements = diff([firstIndex;afterEnd]);

previous = 0;
for k = 1:size(vdIndices,1)
    v = vdIndices(k,1);
    d = vdIndices(k,2);

    rows = previous + (1:nElements);
    svv(v).(field){d} = obj.(field)(rows)';
end

end