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

% Update. Get matfile.
[obj, ens] = obj.updateViaMatfile;

% Default variables and ensemble members
members = obj.members;
variables = obj.variables;
if isempty(members)
    members = 1:obj.meta.nEns;
end
if isempty(variables)
    variables = obj.meta.variableNames;
end

% Check the members and variables are still consistent with the ensemble.
% Get variable indices
[ismem, v] = ismember(variables, obj.meta.variableNames);
if any(~ismem)
    missingVariableError(variables, obj.meta.variableNames, obj.file);
elseif max(members)>obj.meta.nEns
    notEnoughMembersError(max(members), obj.meta.nEns, obj.file);
end

% Get blocks of contiguous variables to load
skips = find(diff(v)~=1)';
nVars = numel(v);
blocks = [1, skips+1; skips, nVars]';
nBlocks = numel(skips)+1;

% Get the limits of loaded variables in the state vector
nEls = obj.meta.nEls(v);
varEnd = cumsum(nEls)';
varLimit = [1, varEnd(1:end-1)+1; varEnd]';
fileMeta = ens.meta;

% Preallocate the ensemble
nState = varLimit(end);
nEns = numel(members);
info = whos(ens, 'X');
X = zeros([nState, nEns], info.class);

% Get equally spaced column indices
loadCols = dash.equallySpacedIndices(members);
keep = ismember(loadCols, members);

% Get the rows for each block of contiguous variables
for k = 1:nBlocks
    loadRows = fileMeta.varLimit(blocks(k,1),1) : fileMeta.varLimit(blocks(k,2),2) ;
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
        X(rows,m) = ens.X(loadRows, members(m));
    end
end

% Build the metadata for the loaded variables and ensemble members
meta = obj.meta.extract(variables);
meta = meta.useMembers(members);
    
end

% Long error messages
function[] = notEnoughMembersError(maxRequested, nEns, file)
error(['You previously requested to load ensemble member %.f. However, ',...
    'the data in file "%s" appears to have changed and now only has %.f ',...
    'ensemble members. You may want to use the "loadMembers" command again.'], ...
    maxRequested, file, nEns);
end
function[] = missingVariableError(requested, vars, file)
bad = find(~ismember(requested, vars), 1);
error(['You previously requested to load data for variable "%s". However, ',...
    'the data in file "%s" appears to have changed and no longer contains ',...
    'this variable. Currently, the variables in the file are: %s. You may ',...
    'want to use the "loadVariables" command again.'], ...
    requested(bad), file, dash.messageList(vars));
end