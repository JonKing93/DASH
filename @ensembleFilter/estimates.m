function[obj] = estimates(obj, Y)
%% Specify the model estimates of the observations/proxies for a filter
%
% obj = obj.estimates(Y)
%
% ----- Inputs -----
%
% Y: The model estimates of observations/proxies. A numeric array that
%    cannot contain NaN or Inf. (nSite x nEns x nPrior)
%
% ----- Outputs -----
%
% obj: The updated ensembleFilter object

% Error check Y and get the size
[nSite, nEns, nPrior] = obj.checkInput(Y, 'Y');

% Check for size conflicts
if ~isempty(obj.D) && nSite~=obj.nSite
    error(['You previously specified observations at %.f sites, but Y includes ',...
        'estimates for %.f sites (rows)'], obj.nSite, nSite);
elseif ~isempty(obj.M) && nEns~=obj.nEns
    error(['You previously specified priors with %.f ensemble members, but Y ',...
        'includes estimates for %.f ensemble members (columns).'], obj.nEns, nEns);
elseif ~isempty(obj.M) && nPrior~=obj.nPrior
    error(['You previously specified %.f prior(s), but Y includes estimates ',...
        'for %.f prior(s) (the length of dimension 3)'], obj.nPrior, nPrior);
end

% Set values
obj.Y = Y;
obj.nSite = nSite;
obj.nEns = nEns;
obj.nPrior = nPrior;

end
    