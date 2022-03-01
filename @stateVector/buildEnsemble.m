function[X, meta, obj] = buildEnsemble(obj, ens, nMembers, strict, grids, coupling, precision, progress)
%% 

% Note whether to display progress
showProgress = false;
if ~isempty(progress)
    showProgress = true;
end

%% Select the new ensemble members:
% 1. Select members and remove overlap
% 2. Record saved / unused members in the state vector object
% 3. Note the number of new members
% 4. Determine precision of output if unset
[obj, nMembers] = selectMembers(obj, nMembers, strict, coupling, progress);


%% gridfile data sources:
% 1. Check data sources can be loaded for required data
% 2. Pre-load data from gridfiles with multiple state vector variables
% 3. Note whether variables can load all ensemble members simultaneously
[sources, loadAllMembers, indexLimits, precision] = ...
          gridSources(obj, nMembers, grids, coupling, precision, progress);


%% Variable build-parameters

% Update progress
if showProgress
    progress.setMessage('Organizing build parameters');
    progress.updateMessage;
end

% Get build parameters for each variable
parameters = cell(obj.nVariables, 1);
for v = 1:obj.nVariables
    parameters{v} = obj.variables_(v).parametersForBuild;
end
parameters = [parameters{:}]';

% Add variable parameters that are determined by the state vector
for v = 1:obj.nVariables
    parameters(v).indexLimits = indexLimits{v};
    parameters(v).loadAllMembers = loadAllMembers(v);
    parameters(v).whichSet = coupling.variables(v).whichSet;
    parameters(v).dims = coupling.variables(v).dims;
end


%% Load / write

% Progress
if showProgress
    progress.setMessage('Testing Sizes');
    progress.update(0);
    progress.startCount(nMembers);
end

% Check single ensemble members can fit in memory
try
    for v = 1:obj.nVariables
        siz = [parameters(v).rawSize, 1, 1];
        NaN(siz);
        if showProgress
            progress.update(v/obj.nVariables);
        end
    end
catch ME
    singleMemberTooLargeError(ME);
end

% Get the indices of the ensemble members
nTotal = obj.members;
members = nTotal-nMembers+1:nTotal;

% Load ensemble directly
metadata = ensembleMetadata(obj);
if isempty(ens)
    X = loadEnsemble(obj, members, grids, sources, parameters, precision, progress, header);

% Or write to file
else
    writeEnsemble(obj, members, grids, sources, parameters, precision, progress, header);
    ens.metadata = metadata.serialize;
    ens.stateVector = obj.serialize;
    X = [];
end

end


% Sub-functions
function[obj, nNew] = selectMembers(obj, nMembers, strict, coupling, progress)
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
%       progress ([] | progressbar object): The progress bar (if any) for
%           selecting ensemble members
%
%   Outputs:
%       obj: The state vector updated with the newly selected ensemble
%           members, and updated set of unused ensemble members.
%       nMembers (scalar integer): The number of new ensemble members selected

% Adjust settings for "all" option
all = false;
if strcmp(nMembers, 'all')
    nMembers = Inf;
    strict = false;
    all = true;
end

% Get initial number of saved and requested ensemble members
nInitial = obj.members;
nRequested = nMembers;

% Preallocate new ensemble members for sets of coupled variables
nSets = numel(coupling.sets);
nNew = NaN(nSets, 1);
incomplete = false(nSets, 1);

% Initialize progress bar
showProgress = false;
if ~isempty(progress)
    showProgress = true;
    progress.setMessage('Selecting Ensemble Members');
    progress.update(0);

    if ~isinf(nMembers)
        progress.max = nMembers * nSets;
    end
end

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
        if nNew(s)+nRemaining<nMembers && ~all
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

        % If all members were selected, update maximum members. Note
        % incomplete variables.
        if incomplete(s) || isinf(nMembers)
            nMembers = nNew(s);
            if incomplete(s)
                incompleteVars = vars;
            end

            % Complete set progress. Exit while loop
            if showProgress
                x = s/nSets;
                progress.update(x);
            end
            break
        end

        % Update progress within while loop
        if showProgress
            x = (s-1)/nSets + (nNew(s)/nMembers)*(1/nSets);
            progress.update(x);
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

% If there were incomplete ensembles, trim each set of ensemble members to
% match the minimum number of members.
if any(incomplete)
    nNew = nNew(end);
    for s = 1:nSets
        obj.subMembers{s} = obj.subMembers{s}(1:nInitial+nNew, :);
    end

    % Notify user of incomplete ensemble
    incompleteEnsembleWarning(obj, incompleteVars, nRequested, nNew, header);
end

% Return the total number of new ensemble members. Report this number if
% the user selected the "all" option
nNew = nNew(1);
if all
    fprintf('Building ensemble with %.f members.\n', nNew);
end

end
function[sources, loadAllMembers, indexLimits, precision] = gridSources(obj, nNew, grids, coupling, precision, progress)
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
%       precision ([] | 'single' | 'double')
%       progress ([] | progressbar object): The progress bar (if any) for
%           checking data sources
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
nMembers = obj.members;
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
varPrecisions = strings(nVars, 1);

% Track precision of loaded data
getPrecision = false;
if isempty(precision)
    getPrecision = true;
end

% Initialize progress bar
if ~isempty(progress)
    progress.setMessage('Collecting Data Sources');
    progress.update(0);
end

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

    % Attempt to build sources. Also record loaded precision
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

    % Record successful sources. Get data precision
    sources(g).dataSources = dataSources;
    sources(g).indices = s;
    if getPrecision
        nSource = numel(s);
        sourcePrecisions = cell(nSource, 1);
        for k = 1:nSource
            sourcePrecisions{s} = dataSources{k}.dataType;
        end
    end

    % If all sources built, and there are 2+ variables, attempt to load
    if allBuilt
        if nVars > 1
            try
                X = grids(g).loadInternal([], indices, s, dataSources);
                sources(g).isloaded = true;
            catch
            end
        end

        % Record successful load, variable should not attempt to load
        % members. Precision is from class of loaded array
        if sources(g).isloaded
            sources(g).data = X;
            sources(g).limits = fullLimits;
            sources(g).dataSources = [];
            sources(g).indices = [];
            if getPrecision && isa(X, 'double')
                getPrecision = false;
                precision = 'double';
            end

        % If too big to load, the arrays for individual variables might be
        % smaller. All necessary sources built, so attempt to load all
        % members. (Or if only a single variable, avoid filling memory).
        else
            loadAllMembers(vars) = true;
            if getPrecision && strcmp(gridfile.loadedPrecision(sourcePrecisions), 'double')
                precision = 'double';
                getPrecision = false;
            end
        end

        % Update progress and move on to the next grid
        if showProgress
            x = g/nGrids;
            progress.update(x);
        end
        continue
    end
    
    % If source failed, check individual variables
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

            % If successful, mark the variable as good.
            [isbuilt, loc] = ismember(sVar, s);
            if all(isbuilt)
                loadAllMembers(v) = true;

                % Get precision
                if getPrecision && strcmp(gridfile.loadedPrecision(sourcePrecisions(loc)), 'double')
                    getPrecision = false;
                    precision = 'double';
                end

                % Update progress bar and move to the next variable
                if showProgress
                    x = (g-1)/nGrids + (k/nVars)*(1/nGrids);
                    progress.update(x);
                    continue
                end
            end
        end

        % If can't load all members, need to check individual ensemble
        % members. Get sources for each member
        for m = 1:nNew
            limits = variable.indexLimits(dims, newMembers(m,:), false);
            indices(dims) = dash.indices.fromLimits(limits);
            sMember = grids(g).sourcesForLoad(indices);

            % If any sources failed, cannot build. Throw error
            [isbuilt, loc] = ismember(sMember, s);
            if ~all(isbuilt)
                failedDataSourceError(obj, grids(g), v, m, sMember, ...
                    failedSources, failureCauses, header);
            end

            % Get precision
            if getPrecision && strcmp(gridfile.loadedPrecision(sourcePrecisions(loc)), 'double')
                getPrecision = false;
                precision = 'double';
            end

            % Update progress bar
            if showProgress
                x = (g-1)/nGrids + (k-1)/nVars + (m/nNew)*(1/nGrids)*(1/nVars);
                progress.update(x);
            end
        end
    end
end

% Use single precision if no data is double
if getPrecision
    precision = 'single';
end

end
function[X] = loadEnsemble(obj, members, grids, sources, parameters, precision, progress, header)
%% Load an entire state vector ensemble directly into memory
% ----------
%   Attempts to load all new ensemble members of all variables directly
%   into memory. Throws an error if unsuccessful.
% ----------
%   Inputs:
%       members (scalar positive integer): The indices of the new members
%           in the set of subscripted ensemble members.
%       grids (scalar struct): Gridfiles and whichGrid
%       sources (scalar struct): Gridfile data sources
%       parameters (struct vector [nVariables]): Build parameters for each variable
%       precision ('single' | 'double'): Numerical precision of the output
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       X (numeric matrix [nState x nMembers]): The loaded state vector ensemble

% Progress bar parameters
if ~isempty(progress)
    progress.ongoing = false;
end

% Attempt to load all variables
vLimit = [1, obj.nVariables];
try
    X = load(vLimit, members, grids, sources, parameters, precision, progress);

% Suggest using .ens file if too large to load directly
catch ME
    if ~strcmp(ME.identifier, 'DASH:stateVector:buildEnsemble:arrayTooBig')
        rethrow(ME);
    end
    tooLargeToLoadError(obj, header);
end

end
function[] = writeEnsemble(obj, members, grids, sources, parameters, precision, progress, header)

%%%%% Parameter for reducing chunk sizes
ORDER = 10;
%%%%%

% Get sizes
nMembers = numel(members);
nVars = obj.nVariables;

% Get the limits of each variable in the state vector
nState = [parameters.nState];
limits = dash.indices.limits(nState);

% Preallocate the ens file
nRows = sum(nState);
ens.X(nRows, members(end)) = NaN(precision);

% Loop through sets of contiguous variables until all variables are loaded
first = 1;
while first <= nVars
    last = nVars;
    tooBig = true;

    % Get a set of contiguous variables
    while last>=first
        vLimit = [first, last];
        rows = limits(first,1):limits(last,2);
        setParameters = parameters(first:last);

        % Attempt to load the set into memory
        isloaded = false;
        try
            X = obj.load(vLimit, members, grids, sources, setParameters, precision);
            isloaded = true;
        catch ME
            if ~strcmp(ME.identifier, 'DASH:stateVector:buildEnsemble:arrayTooBig')
                rethrow(ME);
            end
        end

        % If loaded, write to ens file. Move to next contiguous set of variables
        if isloaded
            ens.X(rows, members) = X;
            tooBig = false;
            break
        end

        % Otherwise, remove 1 variable and try again
        last = last-1;
    end

    % If even a single variable is too large to load, try loading fewer
    % ensemble members at a time.
    if tooBig
        v = first;

        % Find a set of contiguous ensemble members that fits in memory.
        % This is a "chunk". Decrease chunk size by an order of magnitude
        % for each attempt.
        chunkSize = nMembers;
        while chunkSize>1
            chunkSize = ceil(chunkSize/ORDER);
            nChunks = ceil(nMembers/chunkSize);
            allChunksLoaded = false;

            % Get the members to load for each chunk
            for k = 1:nChunks
                use = chunkSize*(k-1) + (1:chunkSize);
                use(use>nMembers) = [];
                chunkMembers = members(use);

                % Attempt to load the chunk
                isloaded = false;
                try
                    X = obj.load([v v], chunkMembers, grids, sources, parameters(v), precision);
                    isloaded = true;
                catch ME
                    if ~strcmp(ME.identifier, 'DASH:stateVector:buildEnsemble:arrayTooBig')
                        rethrow(ME);
                    end
                end

                % If loaded, write to file and continue to the next chunk
                if isloaded
                    ens.X(rows, chunkMembers) = X;
                    if k==nChunks
                        allChunksLoaded = true;
                    end

                % Otherwise, the chunk is too large. Exit the loop to try a
                % smaller chunk size
                else
                    break
                end
            end

            % If all the chunks loaded, the variable is complete. Exit the
            % loop and stop testing chunk sizes
            if allChunksLoaded
                tooBig = false;
                break
            end
        end

        % If still not loaded, cannot load a single ensemble member, so
        % cannot continue. Throw error.
        if tooBig
            cannotLoadSingleMemberError(obj, chunkMembers, v, header);
        end
    end

    % Once the variables are written, move to the next set of variables
    first = last+1;
end

end
function[X] = load(vLimit, members, grids, sources, parameters, precision, progress)
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
    X = NaN(nRows, nMembers, precision);
catch
    id = 'DASH:stateVector:buildEnsemble:arrayTooBig';
    error(id, '');
end

% Note whether to report progress
showProgress = false;
if ~isempty(progress)
    showProgress = true;
end

% Cycle through contiguous variables
vars = vLimit(1):vLimit(2);
for k = 1:numel(vars)
    v = vars(k);

    % Initialize progress bar
    if showProgress && ~progress.ongoing
        progress.setMessage(sprintf('Building "%s"', obj.variableNames(v)));
        progress.update(0);
    end

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
        dims, subMembers, grid, source, parameters(k), progress);
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
function[] = cannotLoadSingleMemberError(obj, m, v, header)

design = '<a href="matlab:dash.doc(''stateVector.design'')">design</a>';
sequence = '<a href="matlab:dash.doc(''stateVector.sequence'')">sequence</a>';
mean = '<a href="matlab:dash.doc(''stateVector.mean'')">mean</a>';

var = obj.variables(v);
vector = '';
if ~strcmp(obj.label, "")
    vector = sprintf('for %s ', obj.name);
end

id = sprintf('%s:cannotLoadSingleMember', header);
ME = MException(id,['Cannot build the ensemble %sbecause ensemble member ',...
    '%.f of variable "%s" is too large to fit in memory. Consider using ',...
    '1. The "%s" method to reduce the number of state vector elements, ',...
    '2. The "%s" method to reduce the number of sequence indices, or ',...
    '3. The "%s" method to reduce the number of mean indices.'],...
    vector, m, var, design, sequence, mean);
throwAsCaller(ME);

end