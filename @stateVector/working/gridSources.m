function[sources, loadAllMembers] = gridSources(obj, grids, coupling, nNew, precision)
%% Builds and error checks gridfile sources before loading data.
% Returns parameters needed to 
%
%
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
%           .isloaded (scalar logical)
%           .data (numeric array)
%           .limits ([nDims x 2])
%           .dataSources (cell vector)
%           .indices: Data source indices
%       loadAllMembers (logical vector [nVariables])

%
%   sources (cell vector [nGrids x 2])
%       [Case 1]: {loaded data, limits}
%       [Case 2]: {dataSources, sourceIndices}
%   isloaded (logical vector [nGrids]): True if a row a sources is case 1.
%       False if it is case 2.
%   limits (cell vector [nVars]):
%       [Case A]: {dimension limits [nDims x 2]}
%       [Case B]: {[]}
%   loadAllMembers (logical vector [nVars]): True if case A, false if case B

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
    sets = coupling.whichSet(vars);

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