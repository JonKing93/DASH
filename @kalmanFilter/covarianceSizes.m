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