function[obj] = observations(obj, Y, header)
%% ensembleFilter.observations  Provide the observations for a filter
% ----------
%   obj = obj.observations(Y, header)
%   Provides the proxy observations to an assimilation filter. The observations
%   must be a numeric matrix. Each row is the observations for a particular
%   site, and each column holds the observations is a particular time step.
%   Time steps without observations should use NaN values. Inf an complex
%   values are not permitted. If Y is empty, deletes the current
%   observations from the filter object.
%
%   If the user previously specified observation uncertainties or
%   estimates, then the number of rows must match the current number of
%   sites. If the user previously provided whichR or whichPrior arguments,
%   then the number of time steps must match the current number of time
%   steps.
% ----------
%   Inputs:
%       Y (numeric matrix [nSite x nTime]): The proxy observations to use
%           in an assimilation filter. A numeric matrix with one row per
%           proxy site, and one column per assimilated time steps. Use NaN
%           for records that lack an observation in a particular time step.
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       obj (scalar ensembleFilter object): The ensembleFilter object with
%           updated proxy observations
%
% <a href="matlab:dash.doc('ensembleFilter.observations')">Documentation Page</a>

% Default
if ~exist('header','var')
    header = "DASH:ensembleFilter:observations";
end

% If empty, delete observations. Optionally reset sizes
if isempty(Y)
    obj = resetObservations(obj);
    return
end

% Initial error checking
try
    name = 'Observations (Y)';
    dash.assert.matrixTypeSize(Y, 'numeric', [], name, header);
    dash.assert.defined(Y, 1, name, header);
    
    % Get size of matrix
    [nSite, nTime] = size(Y);
    
    % Check and set number of sites
    if obj.nSite==0
        obj.nSite = nSite;
    elseif nSite~=obj.nSite
        mismatchSitesError(obj, nSite, header);
    end
    
    % Check and set number of time steps
    if obj.nTime==0
        obj.nTime = nTime;
    elseif nTime~=obj.nTime
        mismatchTimeError;
    end
    
    % Validate observations have R uncertainties
    obj.validateR;

% Minimize error stacks
catch ME
    throwAsCaller(ME);
end

end

%% Utilities
function[obj] = resetObservations(obj)
obj.Y = [];
if isempty(obj.Ye) && isempty(obj.R)
    obj.nSite = 0;
end
if isempty(obj.whichPrior) && isempty(whichR)
    obj.nTime = 0;
end
end

%% Error messages
function[] = mismatchSitesError(obj, nSite, header)
if ~isempty(obj.Ye)
    type = 'estimates';
else
    type = 'uncertainties';
end
id = sprintf('%s:incorrectNumberOfSites', header);
ME = MException(id, ['You previously specified %s for %.f observation sites, ',...
    'so the observations matrix (Y) must have %.f rows. However, Y has %.f ',...
    'rows instead.'], type, obj.nSite, obj.nSite, nSite);
throwAsCaller(ME);
end
function[] = mismatchTimeError(obj, nTime, header)
if ~isempty(obj.whichR)
    type = 'uncertainties';
elseif ~isempty(obj.Ye)
    type = 'estimates';
else
    type = 'priors';
end
id = sprintf('%s:incorrectNumberOfTimeSteps', header);
ME = MException(id, ['You previously specified %s for %.f time steps, so the ',...
    'observations matrix (Y) must have %.f columns. However, Y has %.f columns instead.'],...
    type, obj.nTime, obj.nTime, nTime);
throwAsCaller(ME);
end