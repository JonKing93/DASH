function[] = loadEnsemble(obj, nMembers, coupling, grids, loadAllMembers)

% Load all variables and all new members
vLimit = [1, obj.nVariables];
nTotal = size(obj.subMembers{1},1);
members = nTotal-nMembers+1:nTotal;


X = obj.loadEnsemble(vLimit, members, coupling, grids, loadAllMembers);
end