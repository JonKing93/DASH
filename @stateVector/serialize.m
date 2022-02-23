function[obj] = serialize(obj)
%% stateVector.serialize  Convert stateVector object to a struct that supports fast saving/loading
% ----------
%   obj = obj.serialize
%   Converts a state vector object to a stuct that supports fast save and
%   load operations.
% ----------
%   Outputs:
%       obj (scalar serialized stateVector object): The serialized stateVector
%           object. Supports fast save/load operations, but cannot be used
%           to call most stateVector methods. Use the "deserialize" method
%           to rebuild the original stateVector object.
%
% <a href="matlab:dash.doc('stateVector.serialize')">Documentation Page</a>

% Note serialization
obj.isserialized = true;

% Serialize variables
if ~isempty(obj.variables_)
    obj.variables_ = obj.variables_.serialize;
end

% If still editable, there are no ensemble members. Finished so exit
if obj.iseditable
    return
end

% Get the number of coupling sets
nSets = numel(obj.unused);

% Unused ensemble members
nUnused = NaN(nSets, 1);
for k = 1:nSets
    nUnused(k) = numel(obj.unused{k});
end
obj.unused = cell2mat(obj.unused');
obj.nUnused_serialized = nUnused;

% Saved ensemble members
nMembers = size(obj.subMembers{1}, 1);
nEnsDims = NaN(nSets,1);
for k = 1:nSets
    nEnsDims(k) = size(obj.subMembers{k}, 2);
    obj.subMembers{k} = obj.subMembers{k}(:);
end

obj.subMembers = cell2mat(obj.subMembers');
obj.nMembers_serialized = nMembers;
obj.nEnsDims_serialized = nEnsDims;

end