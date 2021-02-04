function[X] = loadEnsemble(obj, nEns, grids, sets, showprogress)

% Sizes and shorten names
varLimit = obj.variableLimits;
nState = varLimit(end, 2);
nVars = numel(obj.variables);

% Preallocate the output array
try
    X = NaN(nState, nEns);
catch
    outputTooBigError();
end

% Build the ensemble for each variable.
for v = 1:nVars
    rows = varLimit(v,1):varLimit(v,2);
    s = sets(:,v);
    subMembers = obj.subMembers{s}(end-nEns+1:end,:);
    X(rows,:) = obj.variables.loadEnsemble(subMembers, grids.grid(v), grids.source(v), showprogress);
end

end

% Long error message
function[] = outputTooBigError()
error(['The state vector ensemble is too large to fit in active memory, so ',...
    'cannot be provided directly as output. Consider saving the ensemble ',...
    'to a .ens file instead.']);
end