function[s] = serialize(obj)
%% stateVector.serialize  Convert stateVector object to a struct that supports fast saving/loading
% ----------
%   s = obj.serialize
%   Converts a state vector object to a stuct that supports fast save and
%   load operations.
% ----------
%   Outputs:
%       s (scalar struct): A struct that can save/load quickly. The struct
%           can be provided to the deserialize method to rebuild the state
%           vector.
%
% <a href="matlab:dash.doc('stateVector.serialize')">Documentation Page</a>

% Get directly copyable save properties
props = string(properties(obj));
nocopy = ismember(props, ["variables_","unused","subMembers"]);
props(nocopy) = [];

% Build a struct with copyable values
s = struct;
for p = 1:numel(props)
    s.(props(p)) = obj.(props(p));
end

% Get number of coupling sets
nSets = numel(obj.unused);

% Unused ensemble members
nUnused = NaN(nSets, 1);
for k = 1:nSets
    nUnused(k) = numel(obj.unused{k});
end

s.unused = cell2mat(obj.unused');
s.nUnused = nUnused;

% Saved ensemble members
nMembers = size(obj.subMembers{1}, 1);
nEnsDims = NaN(nSets,1);
for k = 1:nSets
    nEnsDims(k) = size(obj.subMembers{k}, 2);
    obj.subMembers{k} = obj.subMembers{k}(:);
end

s.nMembers = nMembers;
s.nEnsDims = nEnsDims;
s.subMembers = cell2mat(obj.subMembers');

% Variable designs
s.variables_ = obj.variables_.serialize;

end