function[obj] = deserialize(obj)
%% stateVector.deserialize  Deserialize a state vector object
% ----------
%   obj = <strong>obj.deserialize</strong>
%   Rebuilds a stateVector object from a serialized object. The
%   deserialized object is valid for stateVector methods.
% ----------
%   Outputs:
%       obj (scalar stateVector object): The deserialized stateVector object
%
% <a href="matlab:dash.doc('stateVector.deserialize')">Documentation Page</a>

% Setup
header = "DASH:stateVector:deserialize";
dash.assert.scalarObj(obj, header);

% Exit if not serialized. Note change in serialization status
if ~obj.isserialized
    return
end
obj.isserialized = false;

% Rebuild variables
obj.variables_ = dash.stateVectorVariable.deserialize(obj.variables_);

% If still editable, there are no ensemble members. Finished so exit
if obj.iseditable
    return
end

% Rebuild unused members
obj.unused = mat2cell(obj.unused, obj.nUnused_serialized, 1)';

% Rebuild subMembers
nSets = numel(obj.nEnsDims_serialized);
nElements = obj.nMembers_serialized * obj.nEnsDims_serialized;
subMembers = mat2cell(obj.subMembers, nElements, 1)';
for k = 1:nSets
    subMembers{k} = reshape(subMembers{k}, obj.nMembers_serialized, obj.nEnsDims_serialized(k));
end
obj.subMembers = subMembers;

% Clear serialization properties
obj.nMembers_serialized = [];
obj.nUnused_serialized = [];
obj.nEnsDims_serialized = [];

end

