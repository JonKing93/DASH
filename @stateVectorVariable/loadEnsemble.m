function[X] = loadEnsemble(obj, subMembers, dims, grid, sources, showprogress)
%% Load the ensemble for a state vector variable

% Convert design options to values for a load operation
[nanflag, siz, meanDims, d, indices, addIndices] = obj.loadSettings(dims);

% Preallocate
nState = prod(obj.stateSize);
nEns = size(subMembers, 1);
X = NaN(nState, nEns);

% Initialize progress bar
if showprogress
    waitname = sprintf('Building "%s":', obj.name);
    waitpercent = ' 0%';
    step = ceil(nEns/100);
    f = waitbar(0, strcat(waitname, waitpercent));
end

% Get the load indices for each ensemble member
for m = 1:nEns
    
    % Add the finished ensemble member to the output array
    [X(:,m), sources] = obj.loadMember(subMembers(m,:), d, siz, indices, addIndices, grid, sources);
    
    % Progress bar
    if showprogress && mod(m,step)==0
        waitpercent = sprintf(' %.f%%', m/nEns*100);
        waitbar(m/nEns, f, strcat(waitname, waitpercent));
    end
end
if showprogress
    delete(f);
end

end