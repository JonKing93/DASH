function[outputs] = validateSizes(outputs, type, name, header)
%% kalmanFilter.validateSizes  Preserve assimilation sizes set by covariance options
% ----------
%   ... = kalmanFilter.validateSizes(outputs, type)
%   When using a dash.ensembleFilter data input method (such as
%   observations, prior, estimates, or uncertainties), the method checks
%   that all essential data inputs have compatible sizes. However,
%   kalmanFilter objects can also set sizes via covariance options. This
%   method ensures that covariance options have compatible sizes and is
%   intended for use after the dash.ensembleFilter method.
%
%   outputs = kalmanFilter.validateSizes(outputs, 'delete')
%   When performing a delete operation, maintains assimilation sizes that
%   are set by the covariance options.
%
%   kalmanFilter.validateSizes(outputs, 'set')
%   When performing a set operation, checks that new sizes are compatible
%   with any sizes set by covariance options.
%
%   ... = kalmanFilter.validateSizes(..., name, header)
%   Customize error messages and IDs.
% ----------
%   Inputs:
%       outputs (cell vector): The output of a dash.ensembleFilter data
%           input method (observations, prior, estimates, uncertainties)
%       type ('delete' | 'set'): Indicates the type of operation performed
%           by the dash.ensembleFilter data input method.
%       name (string scalar): An identifying name for the data input
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       outputs (cell vector): The kalmanFilter object output by a delete
%           operation, but updated to include any sizes set by covariance options.
%       
% <a href="matlab:dash.doc('kalmanFilter.validateSizes')">Documentation Page</a>

% Nothing required if returning values
if strcmp(type, 'return')
    return
end

% Defaults
if ~exist('name','var')
    name = 'inputs';
end
if ~exist('header','var')
    header = "DASH:kalmanFilter:validateSizes";
end

% Otherwise, get the updated object and sizes set by covariance options
obj = outputs{1};
[nSite, nState, nTime] = covarianceSizes(obj);

% If deleting, restore sizes that are still set by covariance options
if strcmp(type, 'delete')
    obj = restoreSizes(obj, nSite, nState, nTime);
    outputs = {obj};

% If setting, check for size conflicts with covariance methods
elseif strcmp(type, 'set')
    ME = assertValidSizes(obj, nSite, nState, nTime, name, header);
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
function[ME] = assertValidSizes(obj, nSite, nState, nTime, name, header)

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
