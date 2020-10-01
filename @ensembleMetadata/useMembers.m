function[obj] = useMembers(obj, members)
%% Updates ensemble metadata to use specific ensemble members.
%
% obj = obj.useMembers(members)
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
members = dash.checkIndices(members, 'members', obj.nEns, 'the number of ensemble members');

% Get the ensemble dimensions for each variable
vars = obj.variableNames;
for v = 1:numel(vars)
    dims = string(fields(obj.metadata.(vars(v)).ensemble));

    % Use the ensemble members in each dimension
    for d = 1:numel(dims)
        meta = obj.metadata.(vars(v)).ensemble.(dims(d));
        if ~isempty(meta)
            obj.metadata.(vars(v)).ensemble.(dims(d)) = meta(members,:);
        end
    end
end

end