function[X, hasnan, g] = loadVariables(obj, first, last, members, g, sets, settings, progress)
%% Loads a set of successive variables in a state vector into memory

% Get the limits of the variables within the loaded set and sizes
varLimit = obj.variableLimits(first:last,:) - obj.variableLimits(fist,1) + 1;
nVars = last - first + 1;
nState = varLimit(end);
nEns = numel(members);

% Preallocate the set of variables. Error ID if too big for memory
try
    X = NaN(nState, nEns);
    hasnan = false(nVars, nEns);
catch
    error("DASH:arrayTooBig", "Could not preallocate output array because the ensemble is too large to fit in memory.");
end

% Get new ensemble members and loading set rows for each variable
for k = 1:nVars
    v = first + k - 1;
    rows = varLimit(k,1):varLimit(k,2);
    subMembers = obj.subMembers{sets(v)}(members, :);
    
    % Load each ensemble member. Update progress bar
    for m = 1:nEns
        j = g.f(v);
        [X(rows, m), g.sources{j}] = obj.variable(v).loadMember(...
            subMembers(m,:), settings(v), g.grids{j}, g.sources{j});
        progress{v}.update;
    end
end

end