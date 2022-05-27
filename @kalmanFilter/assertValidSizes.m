function[] = assertValidSizes(obj, name, header)

% Get the sizes. Initialize errors
[nSite, nState, nTime] = obj.covarianceSizes;
ME = [];

% Number of sites
if nSite>0 && obj.nSite~=nSite
    id = sprintf('%s:wrongNumberSites', header);
    ME = MException(id, ['You previously specified covariance options for ',...
        '%.f observation sites, but the %s are for %.f sites.'], ...
        nSite, name, obj.nSite);

% Number of state vector rows
elseif nState>0 && obj.nState~=nState
    id = sprintf('%s:wrongNumberStateVectorRows', header);
    ME = MException(id, ['You previously specified covariance options for ',...
        '%.f state vector rows, but the %s are for %.f rows.'], ...
        nState, name, obj.nState);

% Number of time steps
elseif nTime>0 && obj.nTime~=nTime
    id = sprintf('%s:wrongNumberTimeSteps', header);
    ME = MException(id, ['You previously specified covariance options for ',...
        '%.f assimilation time steps, but there are %s for %.f time steps.'],...
        nTime, name, obj.nTime);
end

% Minimize error stacks
if ~isempty(ME)
    throwAsCaller(ME);
end

end