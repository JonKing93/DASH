function[varargout] = validateSizes(varargout, type, name, header)

% Nothing require if returning values
if strcmp(type, 'return')
    return
end

% Otherwise, get the updated object and sizes set by covariance options
obj = varargout{1};
[nSite, nState, nTime] = covarianceSizes(obj);

% If deleting, restore sizes that are still set by covariance options
if strcmp(type, 'delete')
    obj = restoreSizes(obj, nSite, nState, nTime);
    varargout = {obj};

% If setting, check for size conflicts with covariance methods
elseif strcmp(type, 'set')
    ME = assertValidSizes(obj, name, header);
    if ~isempty(ME)
        throwAsCaller(ME);
    end
end

end

%% Utility methods
function[nSite, nState, nTime] = covarianceSizes(obj)

% Initialize sizes
nSite = 0;
nTime = 0;
nState = 0;

% Get nTime for time-dependent options
if ~isempty(obj.whichFactor)
    nTime = numel(obj.whichFactor);
elseif ~isempty(obj.whichLoc)
    nTime = numel(obj.whichLoc);
elseif ~isempty(obj.whichBlend)
    nTime = numel(obj.whichBlend);
elseif ~isempty(obj.whichSet)
    nTime = numel(obj.whichSet);
end

% Get nState and nSite for covariance options
if ~isempty(obj.wloc)
    [nState, nSite] = size(obj.wloc, 1:2);
elseif ~isempty(obj.Cblend)
    [nState, nSite] = size(obj.Cblend, 1:2);
elseif ~isempty(obj.Cset)
    [nState, nSite] = size(obj.Cset, 1:2);
end

end
function[obj] = restoreSizes(obj, nSite, nState, nTime)
if nSite > 0
    obj.nSite = nSite;
end
if nTime > 0
    obj.nTime = nTime;
end
if nState > 0
    obj.nState = nState;
end
end
function[ME] = assertValidSizes(obj, name, header)

% Initialize output
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

end
