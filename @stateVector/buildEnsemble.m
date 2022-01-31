function[] = buildEnsemble(obj, nMembers, grids, coupling, strict, precision) 

% Select the new ensemble members. Record the new members in the
% stateVector object and note the number of new members.
[obj, nMembers] = selectMembers(obj, nMembers, strict, coupling);

% Get gridfile sources. Check that data sources can be loaded for all
% required data. Pre-load data from gridfiles with multiple variables.
[sources, loadAllMembers] = gridSources(obj, grids, coupling, nMembers, precision)



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