function[X, grids] = loadVariables(obj, first, last, members, grids, sets, settings, progress)
%% Loads a set of variables into memory
%
% [X, g] = obj.loadVariables(first, last, members, grids, sets, settings, progress)
%
% ----- Inputs -----
%
% first: The index of the first variable to load
%
% last: The index of the last variable to load
%
% members: The ensemble members (in the subMembers array) to load
%
% grids: A structure containing a cell vector of unique gridfile objects, a
%    cell vector containing the dataSource objects for each gridfile, and 
%    an index vector that maps variables to the correpsonding gridfile
%
% sets: A matrix indicating the sets of coupled variables. Each row is one set.
%
% settings: Load settings for the state vector variables. See svv.loadSettings
%
% progress: A set of progressbar objects for the variables
%
% ----- Outputs -----
%
% X: The loaded variables
%
% grids: The updated grid structure with any newly built dataSources

% Get the limits of the variables within the loaded set and sizes
varLimit = obj.variableLimits;
varLimit = varLimit(first:last,:) - varLimit(first,1) + 1;
nVars = last - first + 1;
nState = varLimit(end);
nEns = numel(members);

% Preallocate the set of variables. Error ID if too big for memory
try
    X = NaN(nState, nEns);
catch
    error("DASH:arrayTooBig", "Could not preallocate output array because the ensemble is too large to fit in memory.");
end

% Get new ensemble members and loading set rows for each variable
for k = 1:nVars
    v = first + k - 1;
    g = grids.f(v);
    rows = varLimit(k,1):varLimit(k,2);
    
    subMembers = obj.subMembers{sets(v)}(members, :);
    X(rows,:) = obj.variables(v).loadMembers(...
            subMembers, settings(v), grids.grids{g}, grids.sources{g}, progress{v});
end

end
    
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     subMembers = obj.subMembers{sets(v)}(members, :);
%     
%     % Find the min and max index for each ensemble member.
%     nDims = size(subMembers, 2);
%     limits = NaN(nDims, 2);
%     indices = settings(v).indices;
%     for d = 1:nDims
%         limits(d,1) = min(subMembers(:,d)) + min(settings(v).addIndices{d});
%         limits(d,2) = max(subMembers(:,d)) + max(settings(v).addIndices{d});
%         indices{settings(v).d(d)} = (limits(d,1):limits(d,2))';
%     end
%     
%     % Attempt to load all the necessary data at once
%     [Xm, ~, sources] = grids.grids{g}.repeatedLoad(
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     % Load each ensemble member. Update progress bar
%     for m = 1:nEns
%         g = grids.f(v);
%         [X(rows, m), grids.sources{g}] = obj.variables(v).loadMember(...
%             subMembers(m,:), settings(v), grids.grids{g}, grids.sources{g});
%         progress{v}.update;
%     end
% end
% 
% end