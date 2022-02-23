function[obj] = deserialize(s)
%% stateVector.deserialize  Rebuild a stateVector object from a serialized struct
% ----------
%   obj = obj.deserialize
%   Rebuilds a stateVector object from a serialized struct (produced by the
%   stateVector.serialize method).
% ----------
%   Outputs:
%       obj (scalar stateVector object): The deserialized stateVector object
%
% <a href="matlab:dash.doc('stateVector.deserialize')">Documentation Page</a>

% Initialize object
obj = stateVector;

% Get directly copied fields
props = string(properties(obj));
copy = ~ismember(props, ["variables_","unused","subMembers"]);
copy = props(copy);

% Get copyable values
for p = 1:numel(props)
    field = props(p);
    obj.(field) = s.(field);
end

% Rebuild unused members
obj.unused = mat2cell(s.unused, s.nUnused, 1)';

% Rebuild subMembers
nSets = numel(s.nEnsDims);
nElements = s.nMembers * s.nEnsDims;
subMembers = mat2cell(s.subMembers, nElements, 1)';
for k = 1:nSets
    subMembers{k} = reshape(subMembers{k}, s.nMembers, s.nEnsDims(k));
end
obj.subMembers = subMembers;

% Rebuild variables
obj.variables_ = dash.stateVectorVariable.deserialize(s.variables_);

end

