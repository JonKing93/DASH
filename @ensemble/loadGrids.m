function[s] = loadGrids(obj)
%% Loads data from a .ens file and returns it as gridded climate variables

% Start by loading the state vector ensemble and metadata
[X, meta] = obj.load;

% Initialize an output structure
s = struct();

% Regrid each variable
for v = 1:numel(meta.nEls)
    var = meta.variableNames(v);
    [Xv, gridMeta] = meta.regrid(X, var);
    s.(var) = struct('data', Xv, 'metadata', gridMeta);%, 'members', meta.metadata.ensemble);
end
    
end    
    
    
    