function[] = buildEnsemble(obj, nMembers, strict, grids, whichGrid, ens, showprogress)


% Select the new ensemble members. Informative error if enough ensemble
% members are not found
[obj, newMembers, failed, cause] = selectMembers(obj, nMembers, strict);
if failed
    throwAsCaller(cause);
end

% Either load the data, or build the data source objects for each gridfile
sources = gridSources(obj, newMembers, grids, whichGrid);

end








function[obj, newMembers, failed, cause] = selectMembers(obj, nMembers, strict)
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

% Preallocate new members for sets of coupled variables
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
    [subMembers, unused, status] = selectCoupledMembers(...
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
                        obj, vars, nMembers, strict, unused, savedMembers)

% Get ensemble dimensions and sizes.
variable1 = obj.variables_(vars(1));
[ensDims, ensSize] = variable1.dimensions('ensemble');
nDims = numel(ensDims);

% Initialize dimensionally-subscripted ensemble members
subIndices = cell(1, nDims);
subMembers = savedMembers;

% Initalize ensemble member selection
nInitial = size(subMembers,1);
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
    subMembers = cat(1, subMembers, cell2mat(subIndices)); 

    % Remove overlapping ensemble members from variables that don't allow overlap
    for k = 1:numel(vars)
        v = vars(k);
        if ~obj.allowOverlap(v)
            variable = obj.variables_(v);
            subMembers = variable.removeOverlap(subMembers, ensDims);
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

    % Find all variables that use the gridfile. Preallocate index limits
    vars = find(whichGrid==g);
    nVars = numel(vars);
    limits = NaN(nDims, 2, nVars);

    % Get index limits needed to load new ensemble members for each variable
    for k = 1:nVars
        v = vars(k);
        s = whichSet(v);
        variable = obj.variables_(v);
        limits(:,:,k) = variable.indexLimits(newMembers{s}, obj.ensDims{s});
    end

    % Get the limits of indices needed to load the full set of variables
    minIndex = min(limits(:,1,:), [], 3);
    maxIndex = max(limits(:,2,:), [], 3);
    fullLimits = [minIndex, maxIndex];

    % Get indices that could load the full set of variables
    indices = cell(nDims,1);
    for d = 1:nDims
        indices{d} = min(limits(d,1,:)) : max(limits(d,1,:));
    end

    % Build sources for all variables
    s = grids(g).sourcesForLoad(indices);
    [sources, failed] = grids(g).buildSources(s, false);
    failedSources = s(failed);

    % If successful, attempt to load the full data set and organize as the
    % source for any loads.
    if ~any(failed)
        try
            gridData = grids(g).loadInternal([], indices, s, sources, precision);
            sources(g) = {1, fullLimits, gridData};
        catch
            failed = true;
        end
    end

    % If any failed, process the variables individually







    %%%%%% Process variables individually %%%%%%
    if any(failed)

        % Cycle through variables. Track whether variables
        for v = 1:nVars
            indices = cell(1, nDims);
            for d = 1:nDims
                indices{d} = limits(d,1,v):limits(d,2,v);
            end

            % Determine sources needed to load the variable.
            sVar = grids(g).sourcesForLoad(indices);

            % If all of the sources were succesful, organize the sources
            % for later loads
            if ~any(ismember(sVar, failedSources))
                sources(g) = {2, s(~failed), sources(~failed)};

            % 









