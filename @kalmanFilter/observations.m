function[kf] = observations(kf, D, R)
%% Specify the observations and observation uncertainty for a Kalman Filter
%
% kf = kf.observations(D, R)
%
% ----- Inputs -----
%
% D: The observations/proxy values. A numeric matrix. Each row has the
%    observations for one site over all time steps. Use NaN in time steps
%    with no observations. (nSite x nTime)
%
% R: The observation uncertainty. Use a numeric matrix the size of D 
%    (nSite x nTime) to specify the uncertainty for each observation. Use a
%    scalar (1 x 1) to use the same uncertainty for all observations. If a
%    column vector (nSite x 1), uses a fixed value for each proxy site in
%    all time steps. If a row vector (1 x nTime), uses a fixed value for
%    all proxy sites in each time step.
%
% ----- Outputs -----
%
% kf: The updated kalmanFilter object

% Record current sizes. Do standard filter setup
nSite = kf.nSite;
nTime = kf.nTime;
kf = observations@ensembleFilter(kf, D, R);

% Error check kalman filter settings
if nTime~=kf.nTime && (~isempty(kf.whichLoc)||~isempty(kf.whichCov)||~isempty(kf.whichFactor))
    error(['You previously specified covariance options for %.f time steps, ',...
        'but D has %.f time steps'], nTime, kf.nTime);
elseif nSite~=kf.nSite && (~isempty(kf.Ycov)||~isempty(kf.yloc))
    error(['You previously specified covariance options for %.f sites, ',...
        'but D has %.f sites'], nSite, kf.nSite);
end

end
