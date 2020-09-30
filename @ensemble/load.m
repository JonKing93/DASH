function[] = load(obj)

% Get blocks of contiguous variables to load
skips = find(diff(obj.v)~=1)';
nVars = numel(obj.v);
blocks = [1, skips+1; skips, nVars]';
nBlocks = numel(skips)+1;

% Get the limits of loaded variables in the state vector
nEls = obj.meta.nEls(obj.v);
varEnd = cumsum(nEls)';
varLimit = [1, varEnd(1:end-1)+1; varEnd]';

% Build the matfile object. Check that the .ens file still matches the
% current ensemble object
ens = obj.buildMatfile;
fields = ["hasnan", "meta", "stateVector"];
warning('Build matfile error checking.');

% Preallocate the ensemble
nState = varLimit(end);
nEns = numel(obj.members);
info = whos(ens, 'X');
X = zeros([nState, nEns], info.class);

% Get equally spaced column indices
loadCols = dash.equallySpacedIndices(obj.members);
keep = ismember(loadCols, obj.members);

% Get the rows for each block of contiguous variables
for k = 1:nBlocks
    loadRows = ens.meta.varLimit(blocks(k,1),1) : ens.meta.varLimit(blocks(k,2),2);
    rows = varLimit(blocks(k,1),1) : varLimit(blocks(k,2),2);
    
    % Attempt to load all at once
    try
        Xload = ens.X(loadRows, loadCols);
        X(rows,:) = Xload(:, keep);
        continue
    catch
    end
    
    % Otherwise, load iteratively
    for m = 1:nEns
        X(rows,m) = ens.X(loadRows, obj.members(m));
    end
end
    
end