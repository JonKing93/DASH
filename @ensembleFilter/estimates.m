function[obj] = estimates(obj, Ye, whichPrior)
%% Specify the model estimates of the observations/proxies for a filter
%
% obj = obj.estimates(Ye)
% Specify estimates for static or transient priors to use in each time
% step.
%
% obj = obj.estimates(Ye, whichPrior)
% Specifies which prior / associated set of estimates to use in each time
% step.
%
% ----- Inputs -----
%
% Ye: The model estimates of observations/proxies. A numeric array that
%    cannot contain NaN or Inf. (nSite x nEns x nPrior)
%
% whichPrior: A vector with one element per time step. Each element
%    is the index of the prior to use for that time step. The indices refer
%    to the index along the third dimension of M. (nTime x 1)
%
% ----- Outputs -----
%
% obj: The updated ensembleFilter object

% Check data type and get sizes
[nSite, nEns, nPrior] = obj.checkInput(Ye, 'Ye');

% Default and parse whichPrior
if ~exist('whichPrior','var') || isempty(whichPrior)
    whichPrior = [];
end
resetTime = isempty(obj.Y) && isempty(obj.whichR);
whichPrior = obj.parseWhich(whichPrior, 'whichPrior', nPrior, 'prior', resetTime);
nTime = numel(whichPrior);

% Size checks
if nSite~=obj.nSite
    assert(isempty(obj.Y), sprintf('You previously specified observations for %.f sites, but Ye has %.f sites (rows)', obj.nSite, nSite));
    assert(isempty(obj.R), sprintf('You previously specified R uncertainties for %.f sites, but Ye has %.f sites (rows)', obj.nSite, nSite));
end
if ~isempty(obj.X)
    assert( nEns==obj.nEns, sprintf('You previously specified a prior with %.f ensemble members, but Ye has %.f ensemble members (columns)', obj.nEns, nEns));
    assert( nPrior==obj.nPrior, sprintf('You previously specified a transient prior with %.f priors, but Ye has %.f priors (elements along dimenison 3)', obj.nPrior, nPrior));
end
if nTime~=obj.nTime && ~isempty(whichPrior)
    assert(isempty(obj.Y), sprintf('You previously specified observations for %.f time steps, but here you specify estimates for %.f time steps', obj.nTime, nTime));
    assert(isempty(obj.whichR), sprintf('You previously specified R uncertainties for %.f time steps, but here you specify estimates for %.f time steps', obj.nTime, nTime));
end

% If there is a whichPrior for the prior, require the same time steps
if ~isempty(whichPrior) && ~isempty(obj.whichPrior) && ~isempty(obj.Ye)
    assert(isequal(whichPrior, obj.whichPrior), 'The time steps for these estimates do not match the time steps for the associated transient priors. (check the whichPrior input)');
end

% Save
obj.Ye = Ye;
obj.nSite = nSite;
obj.nEns = nEns;
obj.nPrior = nPrior;

if ~isempty(whichPrior)
    obj.whichPrior = whichPrior;
    obj.nTime = nTime;
end

end