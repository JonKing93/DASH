function[X, meta, obj] = buildEnsemble(obj, ens, nMembers, strict, grids, coupling, showprogress)
%% 

% Select the new ensemble members:
% 1. Select members and remove overlap
% 2. Record saved / unused members in the state vector object
% 3. Note the number of new members
[obj, nMembers] = selectMembers(obj, nMembers, strict, coupling);

% gridfile data sources:
% 1. Check data sources can be loaded for required data
% 2. Pre-load data from gridfiles with multiple state vector variables
% 3. Note whether variables can load all ensemble members simultaneously
[sources, loadAllMembers] = gridSources(obj, nMembers, grids, coupling);

% Variable build-parameters:
% 1. Size of loaded ensemble members (accounting for sequence elements)
% 2. Location of dimensions with means
% 3. Whether variables can load all ensemble members simultaneously
parameters = cell(obj.nVariables, 1);
for v = 1:obj.nVariables
    parameters{v} = obj.variables_(v).parametersForBuild(loadAllMembers(v));
end
parameters = [parameters{:}]';

% Check single ensemble members are not too large
try
    for v = 1:obj.nVariables
        siz = [parameters(v).loadedSize, 1, 1];
        NaN(siz);
    end
catch ME
    singleMemberTooLargeError(ME);
end

% Load ensemble directly
metadata = ensembleMetadata(obj);
if isempty(ens)
    X = loadEnsemble(obj, nMembers, grids, coupling, parameters);

% Or write to file
else
    writeEnsemble(obj, newMembers, grids, sources, whichGrid);
    X = [];
    ens.metadata = metadata.serialize;
    ens.stateVector = obj.serialize;
end

end

% Utility functions
function[obj, nNew] = selectMembers(obj, nMembers, strict, coupling)
%% Selects new ensemble members
% ----------
%  Cycles through sets of coupled variables and selects the required number
%  of new ensemble members. These members are dimensionally-subscripted and
%  the subscripted ensemble members are checked for overlapping data.
%  Overlap is removed (when prohibited), and new members are selected until
%  the number of new ensemble members is satisfied.
% ----------
%   Inputs:
%       nMembers ('all' | scalar positive integer): The number of new
%           members to select
%       strict (scalar logical): 
%       coupling (scalar struct): The output of couplingInfo
%           .sets (struct vector [nSets])
%               .vars (vector, linear indices [nVars]): Variable indices
%               .ensDims (string vector [nDims]): The names of ensemble dimensions
%               .dims (matrix, linear indices [nVars x nDims]): 
%                   Indices of the ensemble dimensions for each variable
%           .variables (struct vector [nVariables])
%               .whichSet (scalar index): The coupling set for the variable
%               .dims (vector, linear indices [nDims]): Indices of the ensemble dimension
%                   *in the order of the coupling set* for the variable
%
%   Outputs:
%       obj: The state vector updated with the newly selected ensemble
%           members, and updated set of unused ensemble members.
%       nMembers (scalar integer): The number of new ensemble members selected

% Adjust for "all" option. Get the initial number of ensemble members
if strcmp(nMembers, 'all')
    nMembers = Inf;
end
nInitial = size(obj.subMembers{1}, 1);

% Preallocate new ensemble members for sets of coupled variables
nSets = numel(coupling.sets);
nNew = NaN(nSets, 1);
incomplete = false(nSets, 1);

% Cycle through sets of coupled variables.
for s = 1:nSets
    set = coupling.sets(s);
    vars = set.vars;

    % Get size of ensemble dimensions
    variable1 = obj.variables_(vars(1));
    ensSize = variable1.ensembleSizes;

    % Initialize indices for dimensionally-subscripted ensemble members
    nDims = numel(set.ensDims);
    subIndices = cell(1, nDims);

    % Initialize ensemble member selection
    subMembers = obj.subMembers{s};
    unused = obj.unused{s};
    nRemaining = numel(unused);
    nNew(s) = 0;

    % Select ensemble members until the ensemble is complete
    while nNew(s) < nMembers
        if nNew(s)+nRemaining<nMembers && ~isinf(nMembers)
            incomplete(s) = true;
        end

        % Throw error if cannot be completed
        if incomplete(s) && strict
            notEnoughMembersError(obj, vars, nMembers, nNew(s), nRemaining, header);
        end

        % Select members, remove from unselected members
        if incomplete(s) || isinf(nMembers)
            nSelected = nRemaining;
        else
            nSelected = nMembers - nNew(s);
        end
        members = unused(1:nSelected);
        unused(1:nSelected) = [];

        % Subscript members over ensemble dimensions. Add to full set of
        % saved ensemble members
        [subIndices{:}] = ind2sub(ensSize, members);
        newMembers = cell2mat(subIndices);
        subMembers = cat(1, subMembers, newMembers);

        % Remove overlapping ensemble members from variables that do no
        % allow overlap. (Remove new members when overlap occurs)
        for k = 1:numel(vars)
            v = vars(k);
            if ~obj.allowOverlap(v)
                variable = obj.variables_(v);
                dims = coupling.variables(v).dims;
                subMembers = variable.removeOverlap(dims, subMembers);
            end
        end
        
        % Update sizes
        nNew(s) = size(subMembers,1) - nInitial;
        nRemaining = numel(unused);

        % If all members were selected, exit loop
        if incomplete(s) || isinf(nMembers)
            break
        end
    end

    % Require at least one ensemble member
    if nNew(s)==0
        noMembersError(obj, vars, header);
    end

    % Record the saved and unused ensemble members
    obj.unused{s} = unused;
    obj.subMembers{s} = subMembers;
end

% If there were incomplete ensembles, find the set of coupled variables
% with the smallest number of new ensemble members
if any(incomplete)
    [nNew, s] = min(nNew);
    vars = coupling.sets(s).vars;

    % Trim each set of ensemble members to match this smaller number and
    % notify user of incomplete ensemble.
    for s = 1:nSets
        obj.subMembers{s} = obj.subMembers{s}(1:nInitial+nNew, :);
    end
    incompleteEnsembleWarning(obj, vars, nMembers, nNew, header);
end

% Return the total number of new ensemble members
nNew = nNew(1);

end
function[sources, loadAllMembers] = gridSources(obj, nNew, grids, coupling)
%% Builds and error checks gridfile sources before loading data.
% ----------
% Builds gridfile dataSources required to load new members. If a gridfile
% is used by multiple variables, attempts to load all data required for the
% variables at once. In the load fails, or if the gridfile has a single
% state vector variable, checks if variables have the data sources
% necessary to load all ensemble members at once.
%
% Loading all members at once is preferred, but if this also fails, then as
% a last resort checks if variables have the data sources required to load
% each ensemble member individually. If this also fails, throws an error.
% ----------
%   Inputs:
%       nNew (scalar integer): The number of new members
%       grids (scalar struct):
%           .whichGrid (numeric vector [nVariables])
%           .gridfiles (gridfile vector [nGrids])
%       coupling (scalar struct)
%           .whichSet (numeric vector [nVariables]):
%           .sets (scalar struct)
%               .vars (numeric vector): Variable indices
%               .ensDims (string vector): Ensemble dimensions
%               .dims (matrix [nVars x nDims]): Ensemble dimension indices
%       precision
%
%   Outputs:
%       sources (struct vector [nGrids]):
%           .isloaded (scalar logical): Whether the data for the gridfile
%                   has been loaded directly
%           .data (numeric array): Loaded data
%           .limits ([nDims x 2]): The index limits of the loaded data within the gridfile
%           .dataSources (cell vector [nBuilt]): Successfully built dataSource
%                   objects for the gridfile
%           .indices (vector, linear indices [nBuilt]): The indices of the
%                   built dataSource objects within the full set of gridfile data sources
%       loadAllMembers (logical vector [nVariables]): Whether each variable
%           has the data sources necessary to load all members at once.
%           Note that this does not guarantee that a variable *actually
%           will* load all members at once, only that a variable should
%           attempt the load.

% Get the indices of new ensemble members
nMembers = size(obj.subMembers{1},1);
newIndices = nMembers-nNew+1:nMembers;

% Unpack gridfile info
whichGrid = grids.whichGrid;
grids = grids.gridfiles;

% Preallocate
nGrids = numel(grids);
sources = struct('isloaded',false, 'data', [], 'limits', [], 'dataSources', [], 'indices', []);
sources = repmat(sources, [nGrids 1]);

nVars = obj.nVariables;
loadAllMembers = false(nVars, 1);
dims = cell(nVars, 1);

% Cycle through gridfiles and get dimensions
for g = 1:nGrids
    dimensions = grids(g).dimensions;
    nDims = numel(dimensions);

    % Find all variables that use the gridfile. Get the coupling set for
    % each variable
    vars = find(whichGrid==g);
    nVars = numel(vars);
    sets = [coupling.variables(vars).whichSet];

    % Get index limits needed to load the new ensemble members for each variable
    limits = NaN(nDims, 2, nVars);
    for k = 1:nVars
        v = vars(k);
        cs = sets(k);

        row = v == coupling.sets(cs).vars;
        dims{v} = coupling.sets(cs).dims(row,:);
        newMembers = obj.subMembers{cs}(newIndices, :);

        limits(:,:,k) = obj.variables_(v).indexLimits(dims{v}, newMembers);
    end

    % Get index limits for full set of variables
    minIndex = min(limits(:,1,:), [], 3);
    maxIndex = max(limits(:,2,:), [], 3);
    fullLimits = [minIndex, maxIndex];
    indices = dash.indices.fromLimits(fullLimits);        

    % Attempt to build sources
    s = grids(g).sourcesForLoad(indices);
    [dataSources, failed, causes] = grids(g).buildSources(s, false);

    % Note if sources built successfully, record failed sources
    allBuilt = true;
    if any(failed)
        allBuilt = false;
        failedSources = s(failed);
        failureCauses = causes(failed);
    end

    % Record successful sources
    sources(g).dataSources = dataSources(~failed);
    sources(g).indices = s(~failed);

    % If dataSources built, and there are 2+ variables, attempt to load
    if allBuilt
        if nVars > 1
            try
                X = grids(g).loadInternal([], indices, s, dataSources, precision);

                % Record if successful
                sources(g).isloaded = true;
                sources(g).data = X;
                sources(g).limits = fullLimits;
                sources(g).dataSources = [];
                sources(g).indices = [];
            catch
            end
        end

        % Even if too big to load, can load individual variables. Move on
        % to the next grid
        loadAllMembers(vars) = true;
        continue;
    end

    % If any sources failed, need to check each variable individually. 
    for k = 1:nVars
        v = vars(k);
        variable = obj.variables_(v);
        indices = dash.indices.fromLimits(limits(:,:,k));
        sVar = grids(g).sourcesForLoad(indices);

        % If successful, note the variable is good and move on to the next
        % variable
        if ~any(ismember(sVar, failedSources))
            loadAllMembers(v) = true;
            continue
        end

        % If not successful, need to check individual ensemble members
        cs = sets(k);
        newMembers = obj.subMembers{cs}(newIndices, :);
        for m = 1:nNew

            % Get index limits, indices, sources for each ensemble member.
            limits = variable.indexLimits(dims{v}, newMembers(m,:));
            indices = dash.indices.fromLimits(limits);
            sMember = grids(g).sourcesForLoad(indices);

            % If source failed, cannot build. Throw error
            if any(ismember(sMember, failedSources))
                failedDataSourceError(obj, grids(g), v, m, sMember, ...
                    failedSources, failureCauses, header);
            end
        end
    end
end

end

% Error messages
function[] = notEnoughMembersError(obj, vars, nMembers, nNew, nRemaining, header)

name = 'coupled variables';
if numel(vars)==1
    name = 'variable';
end

vars = obj.variables(vars);
vars = dash.string.list(vars);

nTotal = nNew + nRemaining;

id = sprintf('%s:notEnoughMembers', header);
error(id, ['Cannot find enough new members to complete the ensemble. You have ',...
    'requested %.f ensemble members, but only %.f ensemble members could',...
    'be found for %s %s.'], nMembers, nTotal, name, vars);
end
function[] = noMembersError(obj, vars, header)

name = 'coupled variables';
if numel(vars)==1
    name = 'variable';
end

vars = obj.variables(vars);
vars = dash.string.list(vars);

id = sprintf('%s:noNewMembers', header);
ME = MException(id, 'Cannot find any new ensemble members for %s %s.',...
    name, vars);
throwAsCaller(ME);

end
function[] = incompleteEnsembleWarning(obj, vars, nMembers, nNew, header)

name = 'coupled variables';
if numel(vars)==1
    name = 'variable';
end

vars = obj.variables(vars);
vars = dash.string.list(vars);

id = sprintf('%s:incompleteEnsemble', header);
warning(id, ['You requested %.f ensemble members but only %.f ensemble members ',...
    'could be found for %s %s. Continuing build with %.f ensemble members.'],...
    nMembers, nNew, name, vars, nNew);

end
function[] = failedDataSourceError(obj, grid, var, m, s, sFailed, causes, header)

[sBad, whichFailure] = ismember(s, sFailed);
cause = causes(whichFailure);

sBad = s(find(sBad,1));
sourcePath = grid.sources(sBad);
[~,name,ext] = fileparts(sourcePath);
sourceName = strcat(name, ext);

id = sprintf('%s:dataSourceFailed', header);
ME = MException(id, ['Cannot build the new ensemble members for %s because a data source file',...
    'failed. New ensemble member %.f for the "%s" variable requires data ',...
    'from gridfile "%s" saved in data source file "%s". However, the data ',...
    'could not be loaded from the source file.\n\n',...
    'Data source file: %s\n',...
    '        gridfile: %s\n'],...
    obj.name, m, var, grid.name, sourceName, sourcePath, grid.file);
ME = addCause(ME, cause);
throwAsCaller(ME);

end

