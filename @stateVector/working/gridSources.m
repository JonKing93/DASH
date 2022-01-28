function[sources, isloaded, limits, loadAllMembers] = gridSources(obj, newMembers, ensDims, grids, whichGrid, precision)
%% Builds and error checks gridfile sources before loading data.
% Returns parameters needed to 
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

% Preallocate
nGrids = numel(grids);
sources = cell(nGrids, 2);
isloaded = false(nGrids, 1);

nVars = obj.nVariables;
varLimits = cell(nVars, 1);
loadAllMembers = false(nVars, 1);

% Get the coupling set for each variable
coupledVars = unique(obj.coupled, 'rows');
[whichSet, ~] = find(coupledVars);

% Cycle through gridfiles and get dimensions
for g = 1:nGrids
    dimensions = grids(g).dimensions;
    nDims = numel(dimensions);

    % Find all variables that use the gridfile. Get each coupling set
    vars = find(whichGrid==g);
    variables = obj.variables_(vars);
    sets = whichSet(vars);
    nVars = numel(vars);

    % Get index limits for each variable
    limits = NaN(nDims, 2, nVars);
    for v = 1:nVars
        cs = sets(v);
        limits(:,:,v) = variables(v).indexLimits(newMembers{cs}, ensDims{cs});
    end
    varLimits(vars) = mat2cell(limits, nDims, 2, ones(nVars,1));

    % Get index limits for full set of variables
    minIndex = min(limits(:,1,:), [], 3);
    maxIndex = max(limits(:,2,:), [], 3);
    fullLimits = [minIndex, maxIndex];
    indices = dash.indices.fromLimits(fullLimits);        

    % Attempt to build sources
    s = grids(g).sourcesForLoad(indices);
    [dataSources, failed] = grids(g).buildSources(s, false);

    % Note if sources built successfully, record failed sources
    allBuilt = true;
    if any(failed)
        allBuilt = false;
        failedSources = s(failed);
    end

    % Begin designing output
    sources = {dataSources(~failed), s(~failed)};

    % If dataSources built, and there are 2+ variables, attempt to load
    if allBuilt
        if nVars > 1
            try
                X = grids(g).loadInternal([], indices, s, dataSources, precision);
                isloaded(g) = true;
                sources(g,:) = {X, fullLimits};
            catch
            end
        end

        % Even if too big to load, can load individual variables. Move on
        % to the next grid
        loadAllMembers(vars) = true;
        continue;
    end

    % If sources failed, need to check each variable individually. 
    for v = 1:nVars
        indices = dash.indices.fromLimits(limits(:,:,v));
        sVar = grids(g).sourcesForLoad(indices);

        % If successful, note the variable is good and move on to the next
        % variable
        if ~any(ismember(sVar, failedSources))
            loadAllMembers(vars(v)) = true;
            continue
        end

        % If not successful, need to check individual ensemble members
        cs = sets(v);
        nMembers = size(newMembers{cs},1);
        for m = 1:nMembers

            % Get index limits, indices, sources for each ensemble member.
            limits = variables(v).indexLimits(newMembers{cs}(m,:), ensDims{cs});
            indices = dash.indices.fromLimits(limits);
            sMember = grids(g).sourcesForLoad(indices);

            % If source failed, cannot build. Throw error
            if any(ismember(sMember, failedSources))
                failedDataSourceError;
            end
        end
    end
end

end