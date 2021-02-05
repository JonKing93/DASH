function[X, g] = loadVariables(obj, first, last, members, g, sets, settings, showprogress)
%% Loads a set of successive variables in a state vector into memory

% Get the limits of the variables within the loaded set and sizes
varLimit = obj.variableLimits(first:last,:) - obj.variableLimits(fist,1) + 1;
nVars = last - first + 1;
nState = varLimit(end);
nEns = numel(members);

% Preallocate the set of variables. Error ID if too big for memory
try
    X = NaN(nState, nEns);
catch
    error("DASH:arrayTooBig", "Could not preallocate output array because the ensemble is too large to fit in memory.");
end

% Get new ensemble members and loading set rows for each variabe
for k = 1:nVars
    v = first + k - 1;
    rows = varLimit(k,1):varLimit(k,2);
    subMembers = obj.subMembers{sets(v)}(members, :);
    
    % Initialize progress bar
    if showprogress
        waitname = sprintf('Building "%s":', obj.variables(v).name);
        waitpercent = ' 0%';
        step = ceil(nEns/100);
        f = waitbar(0, strcat(waitname, waitpercent));
    end
    
    % Load each ensemble member
    for m = 1:nEns
        j = g.f(v);
        [X(rows, m), g.sources{j}] = obj.variable(v).loadMember(...
            subMembers(m,:), settings(v), g.grids{j}, g.sources{j});

        % Update progress bar
        if showprogress && mod(m,step)==0
            waitpercent = sprintf(' %.f%%', m/nEns*100);
            waitbar(m/nEns, f, strcat(waitname, waitpercent));
        end
    end
    if showprogress
        delete(f);
    end
end

end