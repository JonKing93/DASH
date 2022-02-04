function[s] = serialize(obj)
%% dash.stateVectorVariable.serialize  Convert dash.stateVectorVariable vector to a struct that supports fast saving/loading
% ----------
%   s = obj.serialize
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

%% String delimited properties

% Get properties to convert to string, and to comma delimit
convertProps = ["gridSize","isState","stateSize","ensSize","hasSequence",...
    "meanType","meanSize","omitnan","metadataType"];
nConvert = numel(convertProps);

delimitProps = ["dims", convertProps];
nDelimit = nConvert+1;

% Cycle through variables, convert properties to string
for v = 1:nVars
    for p = 1:nConvert
        field = convertProps(p);
        obj(v).(field) = string(obj(v).(field));
    end

    % Comma delimit properties
    for p = 1:nDelimit
        field = delimitProps(p);
        obj(v).(field) = strjoin(obj(v).(field), ',');
    end
end

% Add comma delimited properties to string
for p = 1:nDelimit
    field = delimitProps(p);
    s.(field) = [obj.(field)]';
end

%% Cell vector properties

% Initialize sizes
nDims = NaN(nVars, 1);
nIndices = strings(nVars, 1);
nSequence = strings(nVars, 1);
nMean = strings(nVars, 1);
nWeights = strings(nVars, 1);

% Cycle through variable dimensions. Get sizes and stack indices
for v = 1:nVars
    nDims(v) = numel(obj(v).dims);
    index = NaN(1, nDims(v));
    sequence = NaN(1, nDims(v));
    mean = NaN(1, nDims(v));
    weights = NaN(1, nDims(v));

    % Get size in each dimension
    for d = 1:nDims(v)
        index(d) = numel(obj(v).indices{d});
        sequence(d) = numel(obj(v).sequenceIndices{d});
        mean(d) = numel(obj(v).meanIndices{d});
        weights(d) = numel(obj(v).weights{d});
    end

    % Convert sizes to comma delimited strings
    nIndices(v) = strjoin(string(index),',');
    nSequence(v) = strjoin(string(sequence),',');
    nMean(v) = strjoin(string(mean),',');
    nWeights(v) = strjoin(string(weights),',');

    % Convert cell vectors to column vector stack
    obj(v).indices = cell2mat(obj(v).indices');
    obj(v).sequenceIndices = cell2mat(obj(v).sequenceIndices');
    obj(v).meanIndices = cell2mat(obj(v).meanIndices');
    obj(v).weights = cell2mat(obj(v).weights');
end

% Stack indices in saved structure
s.indices = cell2mat({obj.indices}');
s.sequenceIndices = cell2mat({obj.sequenceIndices}');
s.meanIndices = cell2mat({obj.meanIndices}');
s.weights = cell2mat({obj.weights}');

% Record sizes
s.nDims = nDims;
s.nIndices = nIndices;
s.nSequence = nSequence;
s.nMean = nMean;
s.nWeights = nWeights;


%% Conversion function handle

convertFunction = strings(nVars, 1);
for v = 1:nVars
    convert = strings(1, nDims(v));
    for d = 1:nDims(v)
        convert(d) = string(char(obj(v).convertFunction{d}));
    end
    convertFunction(v) = strjoin(convert, ',');
end


%% Cells with unpredictable elements

% Initialize counts of sequence metadata, metadata, or conversion args
nSeqMeta = 0;
nMetadata = 0;
nArgs = 0;

% Cycle through variables and dimensions. Count cell elements
for v = 1:nVars
    for d = 1:nDims(v)
        if ~isempty(obj(v).sequenceMetadata{d})
            nSeqMeta = nSeqMeta+1;
        end
        if ~isempty(obj(v).metadata_{d})
            nMetadata = nMetadata+1;
        end
        if ~isempty(obj(v).convertArgs{d})
            nArgs = nArgs + numel(obj(v).convertArgs{d});
        end
    end
end

% Preallocate cell elements
sequenceMetadata = cell(nSeqMeta,1);
metadata = cell(nMetadata, 1);
convertArgs = cell(nArgs, 1);

% Also record the variable and dimension associated with each cell element
vdSequenceMetadata = NaN(nSeqMeta, 2);
vdMetadata = NaN(nMetadata, 2);
vdConvertArgs = NaN(nArgs, 2);

% Count current elements
kSeq = 0;
kMeta = 0;
kArgs = 0;

% Cycle through variables and dimensions
for v = 1:nVars
    for d = 1:nDims(v)

        % Sequence meetadata
        if ~isempty(obj(v).sequenceMetadata{d})
            kSeq = kSeq+1;
            sequenceMetadata{kSeq} = obj(v).sequenceMetadata{d};
            vdSequenceMetadata(kSeq,:) = [v d];
        end

        % Alternate metadata
        if ~isempty(obj(v).metadata_{d})
            kMeta = kMeta+1;
            metadata{kMeta} = obj(v).metadata_{d};
            vdMetadata(kMeta,:) = [v d];
        end

        % Conversion args
        if ~isempty(obj(v).convertArgs{d})
            nArgs = numel(obj(v).convertArgs{d});
            kArgs = kArgs + (1:nArgs);
            convertArgs(kArgs) = obj(v).convertArgs{d};
            vdConvertArgs(kArgs,:) = [v d];
        end
    end
end

% Record cells and variable-dimension indices
s.metadata_ = metadata;
s.sequenceMetadata = sequenceMetadata;
s.convertArgs = convertArgs;

s.vdMetadata = vdMetadata;
s.vdSequenceMetadata = vdSequenceMetadata;
s.vdConvertArgs = vdConvertArgs;

end