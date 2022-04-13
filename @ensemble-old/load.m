function[X, meta] = load(obj)
%% Loads data from a .ens file. If specific variables and/or ensemble
% members were requested, then only loads those variables and ensemble
% members.
%
% [X, meta] = obj.load
%
% ----- Outputs -----
%
% X: The loaded state vector ensemble. A numeric matrix. (nState x nEns)
%
% meta: An ensemble metadata object for the loaded ensemble.

% Get matfile. Update. Get load options and check for consistency
ens = obj.buildMatfile;
obj = obj.update(ens);
[members, v] = obj.loadSettings;

% v: Variable index
% blocks: Which segments of v to use per operation

% Get blocks of contiguous variables to load
skips = find(diff(v)~=1)';
nVars = numel(v);
blocks = [1, skips+1; skips, nVars]';
nBlocks = numel(skips)+1;

% Get the limits of loaded variables in the state vector
nEls = obj.metadata.sizes(v);
varEnd = cumsum(nEls)';
varLimit = [1, varEnd(1:end-1)+1; varEnd]';
fileMeta = ensembleMetadata;
fileMeta = fileMeta.buildFromPrimitives(ens.metadata);

% Preallocate the ensemble
nState = varLimit(end);
nEns = numel(members);
info = whos(ens, 'X');
X = zeros([nState, nEns], info.class);

% Get equally spaced column indices
loadCols = dash.indices.equallySpaced(members);
keep = ismember(loadCols, members);

% Get the rows for each block of contiguous variables
vars = obj.metadata.variableNames(v);
for k = 1:nBlocks
    limitVars = vars(blocks(k,:));    
    loadRows = fileMeta.findRows(limitVars(1),1) : fileMeta.findRows(limitVars(2), nEls(blocks(k,2)));    
    rows = varLimit(blocks(k,1),1) : varLimit(blocks(k,2),2);
    
    % Attempt to load all at once
    try
        Xload = ens.X(loadRows, loadCols);
        X(rows,:) = Xload(:, keep);
        continue;
    catch
    end
    
    % Otherwise, load iteratively
    for m = 1:nEns
        X(rows,m) = ens.X(loadRows, members(m));
    end
end

% Build the metadata for the loaded variables and ensemble members
meta = obj.loadedMetadata(v, members);
    
end