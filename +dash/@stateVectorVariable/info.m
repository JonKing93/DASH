function[info] = info(obj)
%% dash.stateVectorVariable.info  Return information about a stateVectorVariable
% ----------
%   info = <strong>obj.info</strong>
%   Returns a struct that organizes information for a stateVectorVariable
%   object. Includes information on the variable's state vector length, and
%   design parameters for each dimension.
% ----------
%   Outputs:
%       info (scalar struct): A struct with information about the
%           stateVectorVariable object. Includes the fields:
%           .length (scalar integer): The number of state vector elements
%               for the variable
%           .dimension_names (string vector): The names of the dimensions
%               in the variable
%           .state_dimensions (string vector): The names of the state
%               dimensions for the variable
%           .ensemble_dimensions (string vector): The names of the ensemble
%               dimensions for the variable
%           .dimensions (struct vector): Organizes design parameters for
%               the variable's dimensions. Has one element per dimension.
%               Fields include the following:
%               .name (string scalar): The name of the dimension
%               .length (scalar integer): The number of state vector
%                   elements associated with the dimension
%               .type (string scalar): Whether the dimension is a state or
%                   an ensemble dimension
%               .state_indices (vector, linear indices): The state indices
%                   for the dimension. Empty if an ensemble dimension.
%               .reference_indices (vector, linear indices): The reference
%                   indices for the dimension. Empty if a state dimension.
%               .sequence (scalar struct | []): Sequence design parameters.
%                   Empty if not using a sequence. If using a sequence, a
%                   scalar struct with fields:
%                   .indices (vector, integers): The sequence indices
%                   .metadata (metadata matrix): Sequence metadata
%               .metadata (scalar struct): Metadata options
%                   .type (string scalar): raw, alternate, or convert
%                   .values (metadata matrix): Alternate metadata values.
%                       Only includes this field when using alternate metadata.
%                   .function (scalar function handle): The conversion
%                       function. Only includes this field when using a
%                       conversion function.
%                   .args (cell row vector): Additional arguments for the
%                       conversion function. Only includes this field when
%                       using a conversion function with additional arguments.
%               .mean (scalar struct): Mean design parameters
%                   .type (string scalar): none, standard, or weighted
%                   .nanflag (string scalar): "omitnan" or "includenan".
%                       Only includes this field when taking a mean.
%                   .indices (vector, integers): Mean indices for ensemble
%                       dimensions. Only includes this field when taking a mean
%                       over an ensemble dimension.
%                   .weights (numeric vector): Weights for a weighted mean.
%                       Only includes this field when taking a weighted mean.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.info')">Documentation Page</a>

% Get summary data for the variable
info = struct('length', prod(obj.stateSize), 'dimension_names', obj.dims,...
    'state_dimensions',obj.dims(obj.isState), 'ensemble_dimensions',obj.dims(~obj.isState));

% Initialize dimension information
nDims = numel(obj.dims);
dimensions = struct('name',[],'type',[],'length',[],'state_indices',[],...
    'reference_indices',[],'sequence',[],'mean',[],'metadata',[]);
dimensions = repmat(dimensions, nDims, 1);

% Get the info for each dimension
for d = 1:nDims
    indices = obj.indices{d};
    if isempty(indices)
        indices = (1:obj.gridSize(d))';
    end

    if obj.isState(d)
        dimensions(d).type = 'state';
        dimensions(d).state_indices = indices;
    else
        dimensions(d).type = 'ensemble';
        dimensions(d).reference_indices = indices;
    end

    dimensions(d).length = obj.stateSize(d);
    dimensions(d).sequence = sequenceInfo(obj, d);
    dimensions(d).mean = meanInfo(obj, d);
    dimensions(d).metadata = metaInfo(obj, d);
end
info.dimensions = dimensions;

end

function[s] = sequenceInfo(obj, d)
s = [];
if obj.hasSequence(d)
    s = struct('indices', obj.sequenceIndices{d},...
        'metadata', obj.sequenceMetadata{d});
end
end
function[s] = meanInfo(obj, d)

s = struct('type','none');

if obj.meanType(d)~=0
    s.type = 'standard';
    if obj.omitnan(d)
        nanflag = "omitnan";
    else
        nanflag = "includenan";
    end
    s.nanflag = nanflag;
    if ~isempty(obj.meanIndices{d})
        s.indices = obj.meanIndices{d};
    end
end

if obj.meanType==2
    s.type = 'weighted';
    s.weights = obj.weights{d};
end

end
function[s] = metaInfo(obj, d)

s = struct('type','raw');
if obj.metadataType(d)==1
    s.type = 'alternate';
    s.values = obj.metadata_{d};
elseif obj.metadataType(d)==2
    s.type = 'convert';
    s.function = obj.convertFunction{d};
    if ~isempty(obj.convertArgs{d})
        s.args = obj.convertArgs{d};
    end
end

end


    