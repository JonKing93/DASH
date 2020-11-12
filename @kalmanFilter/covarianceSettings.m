function[settings] = covarianceSettings(kf)
%% Returns a matrix that indicates the covariance settings used in each
% time step.
%
% settings = kf.covarianceSettings
%
% ----- Outputs -----
%
% settings: First column is which prior, second column is which covariance,
% third column is which localization.

% Defaults
if isempty(kf.whichPrior)
    kf.whichPrior = zeros(1, kf.nTime);
end
if isempty(kf.whichCov)
    kf.whichCov = zeros(1, kf.nTime);
end
if isempty(kf.whichLoc)
    kf.whichLoc = zeros(1, kf.nTime);
end

% Remove prior and localization when the covariance is set directly
if kf.setC
    kf.whichPrior = zeros(1, kf.nTime);
    kf.whichLoc = zeros(1, kf.nTime);
end

% Create the settings matrix
settings = [kf.whichPrior', kf.whichCov', kf.whichLoc'];

end 