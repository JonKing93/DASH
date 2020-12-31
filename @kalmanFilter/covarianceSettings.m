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

% Disregard prior and localization when the covariance is set directly
if kf.setCov
    kf.whichPrior = zeros(kf.nTime, 1);
    kf.whichLoc = zeros(kf.nTime, 1);
    kf.whichFactor = zeros(kf.nTime, 1);
end

% Create the settings matrix
settings = [kf.whichPrior, kf.whichLoc, kf.whichCov, kf.whichFactor];

end 