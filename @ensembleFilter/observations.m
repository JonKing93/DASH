function[obj] = observations2(obj, Y)
%% Specify the observations for a filter
%
% obj = obj.observations(Y)
%
% ----- Inputs -----
%
% Y: The observations/proxy values. A numeric matrix. Each row has the
%    observations for one site over all time steps. Use NaN in time steps
%    with no observations. (nSite x nTime)
%
% ----- Outputs -----
%
% obj: The updated ensembleFilter object

% Error check
[nSite, nTime] = obj.checkInput(Y, 'Y', true, true);

% Check that sizes don't conflict
assert(isempty(obj.whichPrior) || nTime==obj.nTime, sprintf('You previously specified an evolving prior for %.f time steps, but Y has %.f time steps (columns)', obj.nTime, nTime));
assert(isempty(obj.whichR) || nTime==obj.nTime, sprintf('You previously specified R uncertainties for %.f time steps, but Y has %.f time steps (columns)', obj.nTime, nTime));
assert(isempty(obj.R) || nSite==obj.nSite, sprintf('You previously specified observation uncertainties for %.f sites, but Y has %.f sites (rows)', obj.nSite, nSite));
assert(isempty(obj.Ye) || nSite==obj.nSite, sprintf('You previously specified estimates for %.f sites, but Y has %.f sites (rows)', obj.nSite, nSite));

% Set values
obj.nSite = nSite;
obj.nTime = nTime;
obj.Y = Y;

% Check for missing R
obj.checkMissingR;

end