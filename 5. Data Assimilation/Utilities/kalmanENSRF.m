function[K,a] = kalmanENSRF( Mdev, Ydev, R, w )
%% Gets the Kalman Gain and alpha for a Kalman Ensemble Square Root Filter
%
% [K, a] = kalmanENSRF( Mdev, Ydev, R, w )
%
% ----- Inputs -----
%
% Mdev: Model deviations
%
% Y: Observation deviations
%
% R: Observation uncertainty
%
% w: A covariance localization
%
% ----- Outputs -----
%
% K: The kalman gain
%
% a: alpha values. The weights for the adjusted kalman gain.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the coefficient for an unbiased estimator
nEns = size(Mdev,2);
unbias = 1 / (nEns-1);

% Get the numerator
Knum = unbias * Mdev * Ydev';

% Get variance of the deviations
Yvar = var(Ydev);

% Get the denominator
Kdenom = Yvar + R;

% Get the full gain
K = w .* (Knum / Kdenom);

% Get alpha
a = 1 / ( 1 + sqrt(R/Kdenom) );
end