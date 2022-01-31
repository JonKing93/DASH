function[] = buildEnsemble(obj, nMembers, strict, grids, whichGrid, ens, showprogress)


% Select the new ensemble members.
[obj, nNew] = selectMembers(obj, nMembers, strict);

% Get gridfile sources. These can either be loaded data or dataSource objects
[soures, isloaded, limits, loadAllMembers] = gridSources(obj, grids, newMembers);

% Load ensemble directly
metadata = ensembleMetadata(obj);
if isempty(ens)
    X = loadEnsemble(obj, newMembers, grids, sources, whichGrid);

% Or write to file
else
    writeEnsemble(obj, newMembers, grids, sources, whichGrid);
    X = [];
    ens.metadata = metadata.serialize;
    ens.stateVector = obj.serialize;
end

end