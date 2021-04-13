function[kf] = observations(kf, Y)
%% Specify the observations and observation uncertainty for a Kalman Filter
%
% kf = kf.observations(D)
%
% ----- Inputs -----
%
% Y: The observations/proxy values. A numeric matrix. Each row has the
%    observations for one site over all time steps. Use NaN in time steps
%    with no observations. (nSite x nTime)
%
% ----- Outputs -----
%
% kf: The updated kalmanFilter object

% Record current sizes. Do standard filter setup
nSite = kf.nSite;
nTime = kf.nTime;
kf = observations@ensembleFilter(kf, Y);

% Size conflicts for Kalman Filter covariance
assert( nTime==kf.nTime || (isempty(kf.whichLoc)&&isempty(kf.whichCov)&&isempty(kf.whichFactor)), ...
    sprintf(['You previously specified covariance options for %.f time steps, ',...
    'but Y has %.f time steps'], nTime, kf.nTime));
assert(nSite==kf.nSite || (isempty(kf.Ycov)&&isempty(kf.yloc)), sprintf([...
    'You previously specified covariance options for %.f sites, but Y has ',...
    '%.f sites'], nSite, kf.nSite));

end
