function[obj] = useMembers(obj, members)
%% Specify to load specific ensemble members
%
% obj = obj.loadMembers(members)
% Specifies which ensemble members should be loaded in subsequent calls to
% ensemble.load.
%
% ----- Inputs -----
%
% members: A vector of indices indicating which ensemble members to load.
%    Either a vector of linear indices or a logical vector with one element
%    per ensemble member.
%
% ----- Outputs -----
%
% obj: The updated ensemble object

% Update. Error check the ensemble members. Save
obj = obj.update;
members = dash.checkIndices(members, 'members', obj.meta.nEns, 'the number of ensemble members');
obj.members = members(:);

end