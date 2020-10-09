function[obj] = useMembers(obj, members)
%% Specify specific ensemble members to load from a .ens file. By default, 
% all ensemble members are loaded, so this is best used to only load a
% subset of the ensemble members.
%
% obj = obj.useMembers(members)
% Specifies which ensemble members should be loaded in subsequent calls to
% ensemble.load.
%
% ----- Inputs -----
%
% members: A vector of indices indicating which ensemble members to load.
%    Either a vector of linear indices or a logical vector with one element
%    per ensemble member. Use [] to load all ensemble members (the default).
%
% ----- Outputs -----
%
% obj: The updated ensemble object

% Update. Error check the ensemble members. Save
obj = obj.update;
[~, nEns] = obj.meta.sizes;
members = dash.checkIndices(members, 'members', nEns, 'the number of ensemble members');
obj.members = members(:);

end