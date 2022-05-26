function[varargout] = covariance(obj, t, s)
%% kalmanFilter.covariance  Return the current covariance for assimilated time steps
% ----------
%   [C, Ycov] = obj.covariance
%   [C, Ycov] = obj.covariance([])
%   Returns the current Kalman Filter covariance. If using directly-set
%   covariances, returns the directly set values. Otherwise, calculates
%   covariances using the prior and observation estimates, and then applies
%   any inflation, localization, and blending in that order. When
%   calculating covariances, the method requires the filter object to have
%   both a prior and proxy estimates. This syntax also requires the filter
%   to implement a static prior and/or time-independent covariance options.
%   Use the next syntax if the prior or covariance values vary through time.
%
%   The first output is the time-independent covariance between the state
%   vector elements and observation sites. The second output is the
%   time-independent covariance between the observation sites and each
%   other.
%
%   [C, Ycov] = obj.covariance(t)
%   Returns the Kalman filter covariances calculated for the queried time
%   steps. Each element along the third dimension of C and Ycov holds the
%   covariances for a queried time step. This syntax requires that the
%   filter has a defined number of time steps. If not, use the above syntax.
%
%   [C, Ycov] = obj.covariance([], s)
%   [C, Ycov] = obj.covariance( t, s)
%   Only returns covariance values for the queried observation sites. The
%   number of columns of C will match the number of queried sites. Both the
%   number of rows and number of columns of Ycov will match the number of
%   queried sites.
%
%   obj = obj.covariance('reset')
%   Resets all covariance options for the Kalman filter. Deletes any
%   inflation factors, covariance localization, covariance blending, and
%   directly-set covariance values. The resulting filter will only
%   estimate covariance using the prior ensemble and proxy estimates.
% ----------
%   Inputs:
%       t (vector, linear indices [nTime] | logical vector | []): The indices of
%           assimilation time steps for which to return covariance values.
%           If a vector of linear indices, elements should refer to
%           specific time steps in the assimilation. If a logical vector,
%           must have one element per assimilation time step. An empty
%           array is only permitted if the filter uses a static prior
%           and/or time-independent covariance options.
%       s (vector, linear indices [nSite] | logical vector): The indices of
%           observation sites for which to return covariance values. If a
%           vector of linear indices, elements should refer to specific
%           observation sites in the assimilation. If a logical vector,
%           must have one element per site.
%
%   Outputs:
%       C (numeric 3D array [nState x nSite x nTime]): The covariance
%           between the state vector elements and observation sites in the
%           queried time steps.
%       Ycov (numeric 3D array [nSite x nSite x nTime]): The covariance
%           between the observation sites and one another in the queried
%           time steps.
%
% <a href="matlab:dash.doc('kalmanFilter.covariance')">Documentation Page</a>

% Setup
header = "DASH:kalmanFilter:covariance";
dash.assert.scalarObj(obj, header);

% Default
if ~exist('t','var')
    t = [];
end

% Reset. Only allow a single input
if dash.is.strflag(t) && strcmpi(t, 'reset')
    if exist('s','var')
        dash.error.tooManyInputs;
    end

    % Reset all covariance options
    obj = obj.inflate('reset');
    obj = obj.localize('reset');
    obj = obj.blend('reset');
    obj = obj.setCovariance('reset');

    % Collect output and exit
    varargout = {obj};
    return
end

% Require nState and nSite to be set
if obj.nState==0
    missingPriorError(obj, header);
elseif obj.nSite==0
    missingEstimatesError(obj, header);

% If t is empty, require time-independent covariance
elseif isempty(t)
    checkTimeIndependence(obj, header);

% If not empty, require time steps and check indices
else
    if obj.nTime==0
        noTimeError(obj, header);
    end
    logicalReq = 'have one element per assimilation time step';
    linearMax = 'the number of assimilation time steps';
    t = dash.assert.indices(t, obj.nTime, 't', logicalReq, linearMax, header);
end

% If covariance is not set, require a prior and estimates
if isempty(obj.Cset) && (isempty(obj.X) || isempty(obj.Ye))
    missingDataError(obj, header);
end

% If the filter does not have time steps, treat as a 1 time step filter.
if obj.nTime == 0
    t = 1;
    obj.nTime = 1;
    obj.whichSet = 1;
    obj.whichPrior = 1;
    obj.whichFactor = 1;
    obj.whichLoc = 1;
    obj.whichBlend = 1;
end

% Default and error check the queried sites
if ~exist('s','var') || isempty(s)
    s = 1:obj.nSite;
else
    logicalReq = 'have one element per observation site';
    linearMax = 'the number of observation sites';
    s = dash.assert.indices(s, obj.nSite, 's', logicalReq, linearMax, header);
end

% Preallocate
nSite = numel(s);
nTime = numel(t);
C = NaN(obj.nState, nSite, nTime);
Ycov = NaN(nSite, nSite, nTime);

% Determine unique covariances for the queried time steps. Get the
% covariance for each time step while minimizing calculations
[whichCov, nCov] = obj.uniqueCovariances(t);
for c = 1:nCov
    times = whichCov == c;
    t1 = find(times, 1);
    inputs = {t1, s};

    % If estimating covariance, load the prior
    if isempty(obj.Cset)
        p = obj.whichPrior(t1);
        try
            X = obj.loadPrior(p);
        catch cause
            priorFailedError(obj, t1, cause, header);
        end

        % Use decomposed ensembles to estimate covariance
        [~, Xdev] = dash.math.decompose(X);
        [~, Ydev] = dash.math.decompose(obj.Ye(:,:,p));
        inputs = [inputs, {Xdev, Ydev}]; %#ok<AGROW> 
    end

    % Estimate unique covariance for associated time steps
    [C(:,:,times), Ycov(:,:,times)] = obj.estimateCovariance(inputs{:});
end

end

% Error messages
function[] = missingPriorError(obj, header)
id = sprintf('%s:missingPrior', header);
ME = MException(id, 'You must provide a prior for %s before calculating covariance.',...
    obj.name);
throwAsCaller(ME);
end
function[] = missingEstimatesError(obj, header)
id = sprintf('%s:missingEstimates', header);
ME = MException(id, 'You must provide estimates for %s before calculating covariance.',...
    obj.name);
throwAsCaller(ME);
end
function[] = checkTimeIndependence(obj, header)

throwError = true;
if ~isempty(obj.whichPrior)
    type = 'an evolving prior';
elseif ~isempty(obj.whichFactor)
    type = 'time-dependent inflation factors';
elseif ~isempty(obj.whichLoc)
    type = 'time-dependent covariance localization';
elseif ~isempty(obj.whichBlend)
    type = 'time-dependent covariance blending';
elseif ~isempty(obj.whichSet)
    type = 'time-dependent user-specified covariances';
else
    throwError = false;
end

if throwError
    id = sprintf('%s:timeDependentFilter', header);
    ME = MException(id, 't cannot be empty because %s uses %s.', obj.name, type);
    throwAsCaller(ME);
end

end
function[] = missingDataError(obj, header)
try
    if isempty(obj.X)
        missingPriorError(obj, header);
    else
        missingEstimatesError(obj, header);
    end
catch ME
    throwAsCaller(ME);
end
end
function[] = noTimeError(obj, header)
id = sprintf('%s:noTimeSteps', header);
ME = MException(id, 't must be empty because %s has no time steps', obj.name);
throwAsCaller(ME);
end
function[] = priorFailedError(obj, t1, cause, header)

detail = '';
if obj.nTime>1
    detail = sprintf(' in time step %.f', t1);
end

if strcmp(cause.identifier, "DASH:ensemble:load:arrayTooLarge")
    id = sprintf('%s:priorTooLarge', header);
    ME = MException(id, ['Cannot estimate covariance for %s%s because the prior ',...
        'is too large to load into memory. You may need to use a smaller prior.'],...
        obj.name, detail);
    throwAsCaller(ME);
elseif startsWith(cause.identifier, 'DASH')
    id = sprintf('%s:priorFailed',header);
    ME = MException(id, ['Cannot estimate covariance for %s%s because the prior ',...
        'failed to load.'], obj.name, detail);
    ME = addCause(ME, cause);
    throwAsCaller(ME);
else
    rethrow(cause);
end

end

