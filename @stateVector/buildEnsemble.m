function[] = buildEnsemble(obj, nMembers, strict, grids, whichGrid, ens, showprogress)


% Select the new ensemble members.
[newMembers, obj] = selectMembers(obj, nMembers, strict);

% Get gridfile sources. These can either be loaded data or dataSource objects
[whichGrid, sources, failed, cause] = gridSources(obj, grids, newMembers);
if failed
    throwAsCaller(cause);
end

% Load ensemble directly
metadata = ensembleMetadata(obj);
if isempty(ens)
    X = loadEnsemble(obj, newMembers, grids, sources, whichGrid);

% Or write to file
else
    writeEnsemble(obj, newMembers, grids, sources, whichGrid);
    X = [];
    ens.metadata = metadata.serialize;
    ens.stateVector = obj.serialize;
end

end


%% Select ensemble members
function[obj, newMembers] = selectMembers(obj, nMembers, strict)
%% Selects the new ensemble members to be built
%
% Inputs:
%   obj (stateVector object): The main object
%   nMembers ("all" | scalar positive integer): The number of new members
%       to select
%   strict (true | false): Whether to allow incomplete ensembles (false) or
%       whether to throw an error (true)
%
% Outputs:
%   obj (stateVector object): The state vector updated to include the new
%       ensemble members for set of coupled variables
%   newMembers (cell vector [nCoupledSets] {subscripted members [nMembers x nEnsDims]}):
%       The new, dimensionally-subscripted ensemble members for each set of
%       coupled variables.

% Preallocate new members for each set of coupled variables
sets = unique(obj.coupled, 'rows');
nSets = size(sets,1);
newMembers = cell(nSets,1);

% If allowing incomplete ensembles, record details
if ~strict
    incomplete = false(nSets,1);
    nTotal = NaN(nSets, 1);
    incompleteVars = cell(nSets, 1);
end

% Cycle through sets of coupled variables. Note which set each variable
% belongs to
whichSet = NaN(obj.nVariables, 1);
for s = 1:nSets
    vars = find(sets(s,:));
    whichSet(vars) = s;

    % Select new ensemble members for the set
    [newMembers{s}, obj.unused{s}, status] = selectCoupledMembers(...
             obj, vars, nMembers, strict, obj.unused{s}, obj.subMembers{s});




    % Provide error details if failed
    if strcmp(status, 'failed')
        failed = true;
        cause = notEnoughMembersError;
    
    % If incomplete, record details
    elseif strcmp(status, 'incomplete')
        incomplete(s) = true;
        nTotal(s) = size(newMembers, 1);
        incompleteVars{s} = vars;
    end

    % Record the new and unused ensemble members for the set
    newMembers{s} = subMembers;
    obj.unused{s} = unused;
end

% If incomplete, trim each set of new members to match the smallest number
% of selected members
if any(incomplete)
    nTotal = min(nTotal);
    for s = 1:nSets
        newMembers{s} = newMembers{s}(1:nTotal, :);
    end

    % Notify user of incomplete ensemble
    incompleteEnsembleWarning;
end

% Save the complete set of ensemble members (saved and new) for each
% coupled set of variables
for s = 1:nSets
    obj.subMembers{s} = cat(1, obj.subMembers{s}, newMembers{s});
end

end
function[subMembers, unused, status, cause] = selectCoupledMembers(...
                        obj, vars, nMembers, strict, unused, existingMembers)

% Get ensemble dimensions and sizes.
variable1 = obj.variables_(vars(1));
[ensDims, ensSize] = variable1.dimensions('ensemble');
nDims = numel(ensDims);

% Initalize ensemble member selection
subIndices = cell(1, nDims);
nNeeded = nMembers;
nRemaining = numel(unused);

% Select ensemble members (and remove overlapping members) until the
% ensemble is complete. Note if incomplete
incomplete = false;
while nNeeded > 0
    if nNeeded>nRemaining && ~isinf(nNeeded)
        incomplete = true;

        % Throw error if incomplete and strict
        if strict
            status = 'failed';
            cause = notEnoughMembersError;
            return
        end
    end

    % Select members. Remove from set of unselected members
    nSelected = nNeeded;
    if incomplete || isinf(nNeeded)
        nSelected = nRemaining;
    end
    members = unused(1:nSelected);
    unused(1:nSelected) = [];

    % Subscript members over ensemble dimensions.
    [subIndices{:}] = ind2sub(ensSize, members);
    subMembers = cell2mat(subIndices);

    % Remove overlapping ensemble members from variables that don't allow overlap
    for k = 1:numel(vars)
        v = vars(k);
        if ~obj.allowOverlap(v)
            variable = obj.variables_(v);
            allMembers = [existingMembers; subMembers];
            subMembers = variable.removeOverlap(allMembers, ensDims);
        end
    end
    nTotal = size(subMembers, 1);

    % If drawing everything, require at least 1 member, then exit loop
    if incomplete || isinf(nNeeded)
        if nTotal==0
            status = 'failed';
            cause = noMembersError;
            return
        end
        break
    end

    % Update sizes
    nRemaining = numel(unused);
    nTotal = size(subMembers,1);
    nNeeded = nNeeded - (nTotal - nInitial);
    nInitial = nTotal;
end

end


%% Gridfile sources
function[] = gridSources(obj, newMembers, grids, whichGrid)


% In this section, we'll build dataSources and optionally load data from a
% gridfile. Going to use a 3 stage process in order to both
% A. Query the data sources as few times as possible, and
% B. Only require data sources that are absolutely necessary
% 
% The three stages are as follows:
% 1. All variables at once
% 2. All members of individual variables
% 3. Each member individually

% Preallocate
nGrids = numel(grids);
% % sources = cell(nGrids, 1);
% % isloaded = false(nGrids, 1);

% Cycle through gridfiles, get dimensions, preallocate sources
for g = 1:nGrids
    dimensions = grids(g).dimensions;
    nDims = numel(dimensions);

    % Find all variables that use the gridfile. Get their coupling sets
    vars = find(whichGrid==g);
    variables = obj.variables_(vars);
    set = whichSet(vars);
    nVars = numel(vars);

    % Get index limits needed to load all new ensemble members for each variable
    limits = NaN(nDims, 2, nVars);
    for v = 1:nVars
        limits(:,:,v) = variables(v).indexLimits(newMembers{set(v)}, ensDims{set(v)});
    end

    % Get indices needed to load the full set of variables
    minIndex = min(limits(:,1,:), [], 3);
    maxIndex = max(limits(:,2,:), [], 3);
    fullLimits = [minIndex, maxIndex];
    indices = dash.indices.fromLimits(fullLimits);

    % Build sources for these indices
    s = grids(g).sourcesForLoad(indices);
    [sources, failed] = grids(g).buildSources(s, false);

    % If any failed, check each variable individually
    if any(failed)
        failedSources = s(failed);
        for v = 1:nVars
            checkVariable(variables(v), grids(g), limits(:,:,v), ...
                failedSources, ensDims{set(v)}, newMembers{set(v)});
        end
    end
end

end
function[] = checkVariable(variable, grid, limits, failedSources, newMembers)

% Find sources needed to load all ensemble members at once
indices = dash.indices.fromLimits(limits);
s = grid.sourcesForLoad(indices);

% If any sources failed, check each ensemble member
if any(ismember(s, failedSources))
    checkMembers
    nMembers = size(newMembers,1);
    for m = 1:nMembers

        % Get index limits and load indices for each ensemble member
        limits = variable.indexLimits(newMembers(m,:), ensDims);
        for d = 1:nDims
            indices{d} = limits(d,1):limits(d,2);
        end

        % Get sources for ensemble member, throw error if failed
        s = grid.sourcesForLoad(indices);
        if any(ismember(s, failedSources))
            failedDatasourceError;
        end
    end
end

end


%% Load/write

