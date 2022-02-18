function[s] = serialize(obj)
%% dash.stateVectorVariable.serialize  Convert dash.stateVectorVariable vector to a struct that supports fast saving/loading
% ----------
%   s = <strong>obj.serialize</strong>
%   Serializes a vector of stateVectorVariable objects. Converts nested
%   fields to serial arrays. Organizes serial arrays and deserialization
%   parameters in a struct. The struct can be provide to the deserialize
%   method to rebuild the original vector of stateVectorVariable objects.
%
%   In the serialized structure, dimension lists, logical indicators,
%   sizes, and metadata conversion function handles are converted to comma
%   delimited string vectors. (Commas delimit entries for different
%   dimensions). Indices, and mean weights are converted to column vectors,
%   and the numbers of indices in each dimension are stored as comma
%   delimited string vectors. Metadata and conversion function args are
%   stored as cell columns vectors with minimal elements, along with the
%   variable and dimension index associated with each cell element.
% ----------
%   Outputs:
%       s (scalar struct): The serialized state vector variable.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.serialize')">Documentation Page</a>

% Get the number of variables in the object. Initialize struct
nVars = numel(obj);
s = struct();

% Get the number of dimensions in each variable
nDims = NaN(nVars, 1);
for v = 1:nVars
    nDims(v) = numel(obj(v).dims);
end
s.nDims = nDims;

%% String delimited properties

% Convert fields to comma delimited string
logicalFields = ["isState","hasSequence","omitnan"];
numericFields = ["gridSize","stateSize","ensSize","meanSize","meanType","metadataType"];

s = convertJoin(obj, s, nVars, logicalFields, {@single, @string});
s = convertJoin(obj, s, nVars, numericFields, {@string});
s = convertJoin(obj, s, nVars, "dims", {});


%% Cell vector properties
% indices, sequence indices, mean indices, weights

s = stackVectors(obj, s, nVars, nDims, 'indices', 'nIndices');
s = stackVectors(obj, s, nVars, nDims, 'meanIndices', 'nMean');
s = stackVectors(obj, s, nVars, nDims, 'sequenceIndices', 'nSequence');
s = stackVectors(obj, s, nVars, nDims, 'weights', 'nWeights');


%% Cells with elements that cannot be merged

% Extract and stack cell elements
s = extractCells(obj, s, nVars, nDims, 'convertFunction', 'vdConvertFunction');
s = extractCells(obj, s, nVars, nDims, 'sequenceMetadata', 'vdSequenceMetadata');
s = extractCells(obj, s, nVars, nDims, 'metadata_', 'vdMetadata');
s = extractCells(obj, s, nVars, nDims, 'convertArgs', 'vdConvertArgs');

end

% Utility functions
function[str] = join(strs)
str = strjoin(strs, ',');
end
function[s] = convertJoin(obj, s, nVars, fields, convert)
nConvert = numel(convert);
for f = 1:numel(fields)
    field = fields(f);

    for v = 1:nVars
        values = obj(v).(field);
        for k = 1:nConvert
            values = convert{k}(values);
        end
        values = join(values);
        obj(v).(field) = values;
    end
    s.(field) = [obj.(field)]';
end
end
function[s] = stackVectors(obj, s, nVars, nDims, field, countName)

% Initialize sizes
count = strings(nVars, 1);
for v = 1:nVars
    sizes = NaN(1, nDims(v));

    % Get size in each dimension as comma delimited string
    for d = 1:nDims(v)
        sizes(d) = numel(obj(v).(field){d});
    end
    count(v) = join(string(sizes));

    % Convert vectors to column vector stack
    obj(v).(field) = cell2mat(obj(v).(field)');
end

% Stack values for all variables in structure. Record sizes
s.(field) = cell2mat({obj.(field)}');
s.(countName) = count;

end
function[s] = extractCells(obj, s, nVars, nDims, field, vdName)

% Count cells with elements
nCells = 0;
for v = 1:nVars
    for d = 1:nDims(v)
        contents = obj(v).(field){d};
        if ~isempty(contents)

            % Cell vector vs array
            if iscell(contents)
                nCells = nCells + numel(contents);
            else
                nCells = nCells + 1;
            end
        end
    end
end

% Preallocate cell stack and indices
values = cell(nCells, 1);
vdIndices = NaN(nCells, 2);

% Fill cells
k = 0;
for v = 1:nVars
    for d = 1:nDims(v)
        contents = obj(v).(field){d};
        if ~isempty(contents)

            % Cell vector
            if iscell(contents)
                nArgs = numel(contents);
                rows = k + (1:nArgs);
                k = rows(end);
                values(rows) = obj(v).(field){d};
                vdIndices(rows,:) = repmat([v,d], numel(rows), 1);

            % Array
            else
                k = k+1;
                values(k) = obj(v).(field)(d);
                vdIndices(k,:) = [v d];
            end
        end
    end
end

% Record cells and indices
s.(field) = values;
s.(vdName) = vdIndices;

end