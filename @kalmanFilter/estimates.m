function[kf] = estimates(kf, Y)
%% Specify the model estimates of the observations/proxies for a Kalman Filter
%
% kf = kf.estimates(Y)
%
% ----- Inputs -----
%
% Y: The model estimates of observations/proxies. A numeric array that
% cannot contain NaN or Inf. (nSite x nEns x nPrior)
%
% ----- Outputs -----
%
% kf: The updated kalmanFilter object

% Error check Y and get the size
[nSite, nEns, nPrior] = kf.checkInput(Y, 'Y');

% Check there are no size conflicts
if ~isempty(kf.M) && nPrior~=kf.nPrior
    error(['You previously specified %.f prior(s), but Y includes estimates ',...
        'for %.f priors (the length of dimension 3)'], kf.nPrior, nPrior);
elseif ~isempty(kf.M) && nEns~=kf.nEns
    error(['You previously specified priors with %.f ensemble members, but Y ',...
        'includes estimates for %.f ensemble members.'], kf.nEns, nEns);
elseif ~isempty(kf.D) && nSite~=kf.nSite
    error(['You previously specified observations at %.f sites, but Y includes ',...
        'estimates for %.f sites'], kf.nSite, nSite);
end

% Set values
kf.Y = Y;
kf.nSite = nSite;
kf.nEns = nEns;
kf.nPrior = nPrior;

end
    