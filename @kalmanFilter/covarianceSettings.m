function[settings] = covarianceSettings(kf)
%% Returns a matrix that indicates the covariance settings used in each
% time step.
%
% settings = kf.covarianceSettings
%
% ----- Outputs -----
%
% settings: Each column indicates one of the covariance settings. In order:
%    prior, inflation factor, localization, blending/direct covariance

% Collect the settings
settings = [kf.whichPrior, kf.whichFactor, kf.whichLoc, kf.whichCov];

% If the covariance is set directly, ignore prior, localization, and inflation
if kf.setCov
    settings(:, 1:3) = 0;
end

end 