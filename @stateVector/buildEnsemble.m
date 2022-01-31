function[] = buildEnsemble(obj, nMembers, grids, coupling, strict, precision) 

% Structure the information on different sets of coupled 

% Select the new ensemble members.
[obj, nMembers] = selectMembers(obj, nMembers, strict, coupling);

% Get gridfile sources. These can either be loaded data or dataSource objects
[sources, isloaded, varLimits, loadAllMembers] = gridSources(obj, grids, nMembers, precision);

% Load ensemble directly
metadata = ensembleMetadata(obj);
if isempty(ens)
    X = loadEnsemble(obj, nMembers, grids, sources, isloaded, varLimits, loadAllMembers);

% Or write to file
else
    writeEnsemble(obj, newMembers, grids, sources, whichGrid);
    X = [];
    ens.metadata = metadata.serialize;
    ens.stateVector = obj.serialize;
end

end