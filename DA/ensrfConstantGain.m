function[Amean, Adev, calibRatio] = ensrfConstantGain(Mmean, Mdev, D, R, ...
                     Ymean, Ydev, Knum, Ycov, calculateMean, calculateDevs)
%% Updates the ensemble in time steps that use the same Kalman Gain.
% A constant Kalman Gain occurs when time steps are updated using the same
% covariance estimates, observation sites, and observation uncertainties.
%
% [Amean, Adev, calibRatio] = ensrfConstantGain(Mmean, Mdev, D, R, ...
%                    Ymean, Ydev, Knum, Ycov, calculateMean, calculateDevs)
%
% ----- Inputs -----
%
% Mmean: Ensemble mean in multiple time steps. (nState x nTime)
%
% Mdev: Ensemble deviations. (nState x nEns)
%
% D: Observations. (nSite x nTime)
%
% R: Observation uncertainty. (nSite x 1)
%
% Ymean: Y estimate mean. (nState x 1)
%
% Ydev: Y estimate deviations. (nState x nEns)
%
% Knum: Kalman numerator. (nState x nSite)
%
% Ycov: Y estimate covariances. (nSite x nSite)
%
% calculateMean: Scalar logical. Whether to calculate the ensemble mean.
%
% calculateDevs: Scalar logical. Whether to calculate ensemble deviations.
%
% ----- Outputs -----
%
% Amean: Updated ensemble mean
%
% Adev: Updated ensemble deviations
%
% calibRatio: Calibration Ratio

% Default outputs
Amean = [];
Adev = [];

% Get the Kalman Gain
Kdenom = kalmanDenominator(Ycov, R);
K = kalmanGain( Knum, Kdenom );

% Update the mean
if calculateMean
    Amean = updateMean(Mmean, K, D, Ymean);
end

% Calibration ratio
calibRatio = (D - Ymean).^2 ./ diag(Kdenom);

% Update the deviations
if calculateDevs
    Ka = kalmanAdjusted(Knum, Kdenom, R);
    Adev = updateDeviations(Mdev, Ka, Ydev);
end

end