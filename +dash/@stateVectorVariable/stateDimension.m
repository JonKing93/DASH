function[obj] = stateDimension(obj, d, indices)
%% dash.stateVectorVariable.stateDimension  Designs a state dimension
% ----------
%   obj = <strong>obj.stateDimension</strong>(d, indices)
%   Converts a dimension of a state vector variable to a state dimension.
% ----------
%   Inputs:
%       d (scalar positive integer): The index of a dimension in the variable
%       indices (vector, linear indices | []): The state indices for the variable
%
%   Outputs:
%       obj (scalar stateVectorVariable): The updated variable
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.stateDimension')">Documentation Page</a>

% Update design
obj.stateSize(d) = obj.gridSize(d);
if ~isempty(indices)
    obj.stateSize(d) = numel(indices);
end
obj.indices{d} = indices;
obj.ensSize(d) = 1;

% Reset sequences
obj.sequenceIndices{d} = [];
obj.sequenceMetadata{d} = [];

% Reset metadata options
obj.metadataType(d) = 0;
obj.metadata{d} = [];
obj.convertFunction{d} = [];
obj.convertArgs{d} = [];

% Check for size conflict with mean weights
if obj.meanType(D)==3 && obj.meanSize(d)~=obj.stateSize(d)
    weightsSizeConflictError;
end

% Reset mean properties
obj.meanIndices{d} = [];
if obj.meanType~=0
    obj.meanSize(d) = obj.stateSize(d);
    obj.stateSize(d) = 1;
end

end