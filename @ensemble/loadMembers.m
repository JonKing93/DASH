function[obj] = loadMembers(obj, members)
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

% Error check the ensemble members. Save
obj.members = dash.checkIndices(members, 'members', obj.meta.nEns, 'the number of ensemble members');

end
