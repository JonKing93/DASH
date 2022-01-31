function[info] = couplingInfo(obj)
%% Organize information about coupled variables
%

% Get the sets of coupled variables
coupledVars = unique(obj.coupled, 'rows', 'stable');
nSets = numel(coupledVars);

% Preallocate
whichSet = NaN(obj.nVariables,1);
sets = struct('vars', NaN(0,1), 'ensDims', strings(1,0), 'dims', NaN(0,0));
sets = repmat(sets, [nSets, 1]);

% Get the variables in each coupled set
for s = 1:nSets
    vars = find(coupledVars(s,:))';
    nVars = numel(vars);
    whichSet(vars) = s;

    % Get ensemble dimensions
    variable1 = obj.variables_(vars(1));
    ensDims = variable1.dimensions('ensemble');
    nDims = numel(ensDims);

    % Get dimension index of the ensemble dimensions in each coupled variable
    dims = NaN(nVars, nDims);
    for k = 1:nVars
        v = vars(k);
        dims(k,:) = obj.variables_(v).dimensionIndices(ensDims);
    end

    % Record info for each set
    sets(s).vars = vars;
    sets(s).ensDims = ensDims;
    sets(s).dims = dims;
end

% Combine with whichSet for overall information
info = struct('whichSet', whichSet, 'sets', sets);

end