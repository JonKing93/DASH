function[obj] = extractMembers(obj, members)
%% Updates ensemble metadata to use specific ensemble members.
%
% obj = obj.extractMembers(members)
%
% ----- Inputs -----
%
% members: A vector of indices indicating which ensemble members to use.
%    Either a vector of linear indices or a logical vector with one element
%    per ensemble member.
%
% ----- Outputs -----
%
% obj: The updated ensembleMetadata object

% Error check indices
members = dash.assert.indices(members, 'members', obj.nEns, 'the number of ensemble members');

% Get the ensemble dimensions for each variable
vars = obj.variableNames;
for v = 1:numel(vars)
    meta = obj.metadata.(vars(v)).ensemble;
    dims = string(fields(meta));
    
    % Use the ensemble members in each dimension
    for d = 1:numel(dims)
        if ~isempty(meta.(dims(d)))
            obj.metadata.(vars(v)).ensemble.(dims(d)) = meta.(dims(d))(members,:);
        end
    end
end

% Update the number of ensemble members
obj.nEns = numel(members);

end