function[] = writeEnsemble(obj, nEns, g, sets, settings, ens, showprogress)

% Size and shorten names. Get the new ensemble members
varLimit = obj.variableLimits;
nState = varLimit(end, 2);
nVars = numel(obj.variables);

% Preallocate the ens file
cols = size(ens, 'X', 2) + (1:nEns);
ens.X(nState, cols(end)) = NaN;
ens.hasnan(nVars, cols(end)) = false;

% Find sets of subsequent variables that can fit in memory at once
first = 1;
while first <= nVars
    last = nVars;
    tooBig = true;
    
    % Attempt to load a set of variables. If successful, write them to the
    % ens file all at once to minimize write operations
    while last>=first
        try
            [X, g] = obj.loadVariables(first, last, cols, g, sets, settings, showprogress);
            rows = varLimit(first,1):varLimit(last,2);
            ens.X(rows, cols) = X;
            
            % Move on to the next block of variables
            tooBig = false;
            break;
            
        % If it failed because of memory constraints, remove one variable
        % and try again
        catch ME
            if ~strcmpi(ME.identifier, "DASH:arrayTooBig")
                rethrow(ME);
            end
        end
        last = last-1;
    end
    
    % If no success, then the single variable ensemble is too large for memory
    if tooBig
        v = first;
        rows = varLimit(v,1):varLimit(v,2);
        
        % Find a number of ensemble members that does fit in memory (a chunk)
        % Decrease chunk size an order of magnitude for each attempt.
        chunkSize = nEns;
        order = 10;
        while chunkSize>1
            chunkSize = ceil(chunkSize/order);
            nLoad = ceil(nEns/chunkSize);
            
            % Attempt to load each chunk
            try
                for k=1:nLoad
                    use = chunkSize*(k-1)+(1:chunkSize);
                    use(use>nEns) = [];
                    members = cols(use);
                    [X, g] = obj.loadVariables(v, v, members, g, sets, settings, showprogress);
                    
                    % Write to file
                    ens.X(rows, members) = X;
                end
                tooBig = false;
                break;
                
            % Retry if memory issues prevented load
            catch ME
                if ~strcmpi(ME.identifier, "DASH:arrayTooBig")
                    rethrow(ME);
                end
            end
        end
        
        % Throw error if the loop exited without success (this should never
        % happend because of the preallocation check in sv.buildEnsemble)
        if tooBig
            tooBigError(obj.variables(v).name);
        end
    end
    
    % Move to the next set of variables
    first = last+1;
end

end