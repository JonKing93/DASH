function[obj] = deserialize(obj)
%% stateVector.deserialize  Deserialize a state vector object
% ----------
%   obj = obj.deserialize
%   Rebuilds a stateVector object from a serialized object. The
%   deserialized object is valid for stateVector methods.
% ----------
%   Outputs:
%       obj (scalar stateVector object): The deserialized stateVector object
%
% <a href="matlab:dash.doc('stateVector.deserialize')">Documentation Page</a>

% Rebuild unused members
obj.unused = mat2cell(obj.unused, obj.nUnused, 1)';

% Rebuild subMembers
nSets = numel(obj.nEnsDims);
nElements = obj.nMembers * obj.nEnsDims;
subMembers = mat2cell(obj.subMembers, nElements, 1)';
for k = 1:nSets
    subMembers{k} = reshape(subMembers{k}, obj.nMembers, obj.nEnsDims(k));
end
obj.subMembers = subMembers;

% Rebuild variables
obj.variables_ = dash.stateVectorVariable.deserialize(obj.variables_);

end

