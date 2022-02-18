function[obj] = serialize(obj, svv)
%% dash.stateVectorVariable.serialize  Convert dash.stateVectorVariable vector to a struct that supports fast saving/loading
% ----------
%   obj = <strong>obj.serialize</strong>(svv)
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
%   Inputs:
%       svv (vector, stateVectorVariable objects): The vector of
%           stateVectorVariable objects that should be serialized.
%
%   Outputs:
%       obj (scalar serializedStateVectorVariable object): The serialized
%           set of state vector variables.
%
% <a href="matlab:dash.doc('dash.serializedStateVectorVariable.serialize')">Documentation Page</a>

% Get the number of variables in the object.
nVars = numel(svv);

% Get the number of dimensions in each variable
nDims = NaN(nVars, 1);
for v = 1:nVars
    nDims(v) = numel(svv(v).dims);
    if nDims(v)==0
        throwAsCaller(emptyVariableError(v));
    end
end
obj.nDims = nDims;

%% String delimited properties

% Convert function handles to char
for v = 1:nVars
    for d = 1:nDims(v)
        svv(v).convertFunction{d} = char(svv(v).convertFunction{d});
    end
end

% Convert fields to comma delimited string
logicalFields = ["isState","hasSequence","omitnan"];
numericFields = ["gridSize","stateSize","ensSize","meanSize","meanType","metadataType"];

obj = convertJoin(obj, svv, nVars, logicalFields, {@single, @string});
obj = convertJoin(obj, svv, nVars, [numericFields, "convertFunction"], {@string});
obj = convertJoin(obj, svv, nVars, "dims", {});


%% Cell vector properties
% indices, sequence indices, mean indices, weights

obj = stackVectors(obj, svv, nVars, nDims, 'indices', 'nIndices');
obj = stackVectors(obj, svv, nVars, nDims, 'meanIndices', 'nMean');
obj = stackVectors(obj, svv, nVars, nDims, 'sequenceIndices', 'nSequence');
obj = stackVectors(obj, svv, nVars, nDims, 'weights', 'nWeights');


%% Cells with unpredictable elements

% Extract and stack cell elements
obj = extractCells(obj, svv, nVars, nDims, 'sequenceMetadata', 'vdSequenceMetadata');
obj = extractCells(obj, svv, nVars, nDims, 'metadata_', 'vdMetadata');
obj = extractCells(obj, svv, nVars, nDims, 'convertArgs', 'vdConvertArgs');

end

% Utility functions
function[str] = join(strs)
str = strjoin(strs, ',');
end
function[obj] = convertJoin(obj, svv, nVars, fields, convert)
nConvert = numel(convert);
for f = 1:numel(fields)
    field = fields(f);

    for v = 1:nVars
        values = svv(v).(field);
        for k = 1:nConvert
            values = convert{k}(values);
        end
        values = join(values);
        svv(v).(field) = values;
    end
    obj.(field) = [svv.(field)]';
end
end
function[obj] = stackVectors(obj, svv, nVars, nDims, field, countName)

% Initialize sizes
count = strings(nVars, 1);
for v = 1:nVars
    sizes = NaN(1, nDims(v));

    % Get size in each dimension as comma delimited string
    for d = 1:nDims(v)
        sizes(d) = numel(svv(v).(field){d});
    end
    count(v) = join(string(sizes));

    % Convert vectors to column vector stack
    svv(v).(field) = cell2mat(svv(v).(field)');
end

% Stack values for all variables in structure. Record sizes
obj.(field) = cell2mat({svv.(field)}');
obj.(countName) = count;

end
function[obj] = extractCells(obj, svv, nVars, nDims, field, vdName)

% Count cells with elements
nCells = 0;
for v = 1:nVars
    for d = 1:nDims(v)
        contents = svv(v).(field){d};
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
        contents = svv(v).(field){d};
        if ~isempty(contents)

            % Cell vector
            if iscell(contents)
                nArgs = numel(contents);
                rows = k + (1:nArgs);
                k = rows(end);
                values(rows) = svv(v).(field){d};
                vdIndices(rows,:) = repmat([v,d], numel(rows), 1);

            % Array
            else
                k = k+1;
                values(k) = svv(v).(field)(d);
                vdIndices(k,:) = [v d];
            end
        end
    end
end

% Record cells and indices
obj.(field) = values;
obj.(vdName) = vdIndices;

end

% Error messages
function[ME] = emptyVariableError(v)
id = 'DASH:serializedStateVectorVariables:serialize';
ME = MException(id, ['Cannot serialize state vector variables because ',...
    'variable %.f has no dimensions.'], v);
end