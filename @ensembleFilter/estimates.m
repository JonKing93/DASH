function[obj] = estimates(obj, Ye)
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

% Require observations and a prior
assert(~isempty(obj.Y), 'You must provide observations before you specify observation estimates');
assert(~isempty(obj.X), 'You must provide a prior before you specify observation estimates');

% Error check and get the size
[nSite, nEns, nPrior] = obj.checkInput(Ye, 'Ye');

% Check for size conflicts
assert(isempty(obj.Y)||nSite==obj.nSite, sprintf('You previously specified observations for %.f sites, but Ye has %.f sites (rows)', obj.nSite, nSite));
assert(isempty(obj.X)||nEns==obj.nEns, sprintf('You previously specified a prior with %.f ensemble members, but Ye has %.f ensemble members (columns', obj.nEns, nEns));
assert(isempty(obj.X)||nPrior==obj.nPrior, sprintf('You previously specified %.f priors, but Ye has %.f priors', obj.nPrior, nPrior));

% Set values
obj.Ye = Ye;

end