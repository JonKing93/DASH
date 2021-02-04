function[] = writeEnsemble(obj, nEns, grids, sets, ens, showprogress)

% Sizes, shorten names
varLimit = obj.variableLimits;
nState = varLimit(end, 2);
nVars = numel(obj.variables);
nCols = size(ens, 'X', 2);

% Preallocate space in the .ens file
newEnd = nCols + nEns;
ens.X(nState, newEnd) = NaN;
ens.hasnan(nVars, newEnd) = false;

% Walk through sets of subsequent variables. Attempt to load as many into
% memory as possible at once
v = 1;
while v <= nVars
    last = nVars;
    load = false;
    while last >= v
        
        % Attempt to preallocate the set of variables. If possible, can
        % load full variable ensembles directly into memory.
        nRows = varLimit(last,2) - varLimit(v,1) + 1;
        try
            X = NaN(nRows, nEns);
            load = true;
            break;
        catch
        end
        
        last = last-1;
    end
    
    % If variables can be loaded into memory, preallocate
    if load
        loadLimit = varLimit(v:last,:) - varLimit(v,1) + 1;
        nLoad = last-v+1;
        X = NaN(loadLimit(end,2), nEns);
        hasnan = false(nLoad, nEns);
        
        % Load each variable into memory
        for k = 1:nLoad
            rows = loadLimit(k,1):loadLimit(k,2);
            s = sets(:,v+k-1);
            subMembers = obj.subMembers{s}(end-nEns+1:end,:);
            subOrder = obj.dims{s};
            [X(rows,:), hasnan(k,:)] = obj.variables(v).loadEnsemble( ...
                subMembers, subOrder, grids.grid(v+k-1), grids.source(v+k-1), showprogress);
        end
        
        % Write as many variables as possible at once to minimize write operations
        rows = varLimit(v,1):varLimit(last,2);
        newCols = nCols + (1:nEns);
        ens.X(rows, newCols) = X;
        ens.hasnan(v:last, newCols) = hasnan;
    
    % Otherwise, the first variable is too large to fit in memory at once.
    % Write directly to file in chunks
    else
        
        % Determine chunk size
        
        % Load chunks directly to memory
        
        % Write chunks to ens file
        
        