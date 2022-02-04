function[X, meta, obj] = buildEnsemble(obj, ens, nMembers, strict, grids, coupling, showprogress)
%% 

%% Select the new ensemble members:
% 1. Select members and remove overlap
% 2. Record saved / unused members in the state vector object
% 3. Note the number of new members
[obj, nMembers] = selectMembers(obj, nMembers, strict, coupling);


%% gridfile data sources:
% 1. Check data sources can be loaded for required data
% 2. Pre-load data from gridfiles with multiple state vector variables
% 3. Note whether variables can load all ensemble members simultaneously
[sources, loadAllMembers, indexLimits] = ...
                              gridSources(obj, nMembers, grids, coupling);


%% Variable build-parameters

% Get build parameters for each variable
parameters = cell(obj.nVariables, 1);
for v = 1:obj.nVariables
    parameters{v} = obj.variables_(v).parametersForBuild;
end
parameters = [parameters{:}]';

% Get the limits of each variable in the state vector
nState = [parameters.nState];
limits = dash.indices.limits(nState);

% Add variable parameters that are determined by the full state vector
for v = 1:obj.nVariables
    parameters(v).vectorLimits = limits(v,:);
    parameters(v).indexLimits = indexLimits{v};
    parameters(v).loadAllMembers = loadAllMembers(v);
    parameters(v).whichSet = coupling.variables(v).whichSet;
    parameters(v).dims = coupling.variables(v).dims;
end


%% Load / write

% Check single ensemble members can fit in memory
try
    for v = 1:obj.nVariables
        siz = [parameters(v).rawSize, 1, 1];
        NaN(siz);
    end
catch ME
    singleMemberTooLargeError(ME);
end

% Load ensemble directly
metadata = ensembleMetadata(obj);
if isempty(ens)
    X = loadEnsemble(obj, nMembers, grids, sources, parameters);

% Or write to file
else
    writeEnsemble(obj, newMembers, grids, sources, whichGrid);
    X = [];
    ens.metadata = metadata.serialize;
    ens.stateVector = obj.serialize;
end

end


% Sub-functions
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

        % Remove overlapping ensemble members from variables that do not
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

% Return the total number of new ensemble members. Report this number if
% the user selected the "all" option
nNew = nNew(1);
if isinf(nMembers)
    fprintf('Building ensemble with %.f members.\n', nNew);
end

end
function[sources, loadAllMembers, indexLimits] = gridSources(obj, nNew, grids, coupling)
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
%       indexLimits (cell vector [nVariables] {index limits [nDims x 2]}):
%           The index limits along each gridfile dimension required to load
%           all ensemble members for a variable.

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
indexLimits = cell(nVars, 1);

% Cycle through gridfiles. Get variables that use the file and get coupling sets
for g = 1:nGrids
    vars = find(whichGrid==g);
    nVars = numel(vars);
    whichSets = [coupling.variables(vars).whichSet];

    % Get index limits needed to load the new ensemble members for each variable
    for k = 1:nVars
        v = vars(k);
        cs = whichSets(k);

        dims = coupling.variables(v).dims;
        newMembers = obj.subMembers{cs}(newIndices,:);
        indexLimits{k} = obj.variables_(v).indexLimits(dims, newMembers, nVars>1);
    end

    % If there are multiple variables, get index limits for the full set
    if nVars>1
        limits = reshape(indexLimits(vars), [1 1 nVars]);
        limits = cell2mat(limits);
        
        minIndex = min(limits(:,1,:), [], 3);
        maxIndex = max(limits(:,2,:), [], 3);
        fullLimits = [minIndex, maxIndex];
        indices = dash.indices.fromLimits(fullLimits);

    % Otherwise, get index limits for ensemble dimensions, but use state
    % indices directly for state dimensions
    else
        indices = obj.variables_(v).indices;
        indices(dims) = dash.indices.fromLimits(indexLimits{v});
    end

    % Attempt to build sources
    s = grids(g).sourcesForLoad(indices);
    [dataSources, failed, causes] = grids(g).buildSources(s, false);

    % Note if sources built successfully, separate failed sources from
    % successful sources
    allBuilt = true;
    if any(failed)
        allBuilt = false;
        failedSources = s(failed);
        failureCauses = causes(failed);
        s = s(~failed);
        dataSources = dataSources(~failed);
    end

    % Record successful sources
    sources(g).dataSources = dataSources;
    sources(g).indices = s;

    % If all sources built, and there are 2+ variables, attempt to load
    if allBuilt
        if nVars > 1
            sources(g).isloaded = true;
            try
                X = grids(g).loadInternal([], indices, s, dataSources);
            catch
                sources(g).isloaded = false;
            end

            % Record successful load. Variable should not attempt to load members
            if sources(g).isloaded
                sources(g).data = X;
                sources(g).limits = fullLimits;
                sources(g).dataSources = [];
                sources(g).indices = [];
            end
            continue
        end

        % If too big to load, the arrays for individual variables might be
        % smalle. All necessary sources built, so move on to the next grid
        loadAllMembers(vars) = true;
        continue
    end

    % If sources failed, need to check each variable individually
    for k = 1:nVars
        v = vars(k);
        variable = obj.variables_(v);
        indices = variable.indices;

        % Get coupling set and ensemble members
        dims = coupling.variables(v).dims;
        cs = whichSets(k);
        newMembers = obj.subMembers{cs}(newIndices,:);

        % If there were 2+ variables, check if all members can be loaded
        if nVars>1
            limits = variable.indexLimits(dims, newMembers, false);
            indices(dims) = dash.indices.fromLimits(limits);
            sVar = grids(g).sourcesForLoad(indices);

            % If successful, mark the variable as good and move to the next variable
            if ~any(ismember(sVar, failedSources))
                loadAllMembers(v) = true;
                continue
            end
        end

        % If can't load all members, need to check individual ensemble
        % members. Get index limits and indices for each member
        for m = 1:nNew
            limits = variable.indexLimits(dims, newMembers(m,:), false);
            indices(dims) = dash.indices.fromLimits(limits);

            % If any sources failed, cannot build. Throw error
            sMember = grids(g).sourcesForLoad(indices);
            if any(ismember(sMember, failedSources))
                failedDataSourceError(obj, grids(g), v, m, sMember, ...
                    failedSources, failureCauses, header);
            end
        end
    end
end

end
function[X] = loadEnsemble(obj, nMembers, grids, sources, parameters, header)
%% Load an entire state vector ensemble directly into memory
% ----------
%   Attempts to load all new ensemble members of all variables directly
%   into memory. Throws an error if unsuccessful.
% ----------
%   Inputs:
%       nMembers (scalar positive integer): The number of new ensemble
%           members to load
%       grids (scalar struct): Gridfiles and whichGrid
%       sources (scalar struct): Gridfile data sources
%       parameters (struct vector [nVariables]): Build parameters for each variable
%
%   Outputs:
%       X (numeric matrix [nState x nMembers]): The loaded state vector ensemble

% Select all variables and all new members
vLimit = [1, obj.nVariables];
nTotal = size(obj.subMembers{1},1);
members = nTotal-nMembers+1:nTotal;

% Load everything
try
    X = load(vLimit, members, grids, sources, parameters, header);

% Suggest using .ens file if too large to load directly
catch ME
    if ~strcmp(ME.identifier, 'DASH:stateVector:buildEnsemble:arrayTooBig')
        rethrow(ME);
    end
    tooLargeToLoadError(obj, header);
end

end
function[X] = load(vLimit, members, grids, sources, parameters, header)
%% Loads indicated ensemble members for a continuous set of variables in a state vector
%
% Inputs:
%   vLimit (vector, linear indices [2]): The index limits of the continuous
%       set of variables that should be loaded
%   members (vector, linear indices): The indices of the ensemble members
%       that should be loaded.
%   grids (scalar struct): Gridfiles and whichGrid
%   sources (struct vector [nGrids]): Gridfile data sources
%   parameters (struct vector [nVariables]): Build parameters for the
%       variables being loaded.
%
% Outputs:
%   X (numeric matrix [nState x nMembers]): The loaded ensemble members

% Get limits of each variable in the loaded set
nState = [parameters.nState];
limits = dash.indices.limits(nState);

% Preallocate. Tag error if too large
nRows = sum(nState);
nMembers = numel(members);
try
    X = NaN(nRows, nMembers);
catch
    id = 'DASH:stateVector:buildEnsemble:arrayTooBig';
    error(id, '');
end

% Cycle through contiguous variables
vars = vLimit(1):vLimit(2);
for k = 1:numel(vars)
    v = vars(k);

    % Get the gridfile and sources for each variable
    g = grids.whichGrid(v);
    grid = grids.gridfiles(g);
    source = sources(g);

    % Get the ensemble members to build
    s = parameters(k).whichSet;
    subMembers = obj.subMembers{s}(members, :);
    dims = parameters(k).dims;

    % Load the ensemble members for each variable
    rows = limits(k,1):limits(k,2);
    X(rows,:) = obj.variables_(v).buildMembers(...,
        dims, subMembers, grid, source, parameters(k));
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
function[] = tooLargeToLoadError(obj)

vector = '';
if ~strcmp(obj.label,"")
    vector = sprintf('for %s ', obj.name);
end

design = '<a href="matlab:dash.doc(''stateVector.design'')">stateVector.design</a>';

id = sprintf('%s:ensembleTooLargeToLoad', header);
ME = MException(id, ['The state vector ensemble %sis too large to be loaded into ',...
    'active memory, so cannot be returned directly as output. Consider ',...
    '1. Using the "file" option to save the ensemble to a .ens file instead, ',...
    '2. Building fewer ensemble members, or 3. Using %s to select fewer ',...
    'state vector elements.'],...
    vector, design);
throwAsCaller(ME);
end
