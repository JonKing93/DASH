function[K, a] = serialKalman( Mdev, Ydev, w, R )
%% Gets the Kalman Gain and alpha for a Kalman Ensemble Square Root Filter
%
% [K, a] = kalmanENSRF( Mdev, ydev, w, R )
% Computes the kalman gain and alpha scaling factor for a serial update.
%
% ----- Inputs -----
%
% Mdev: Model deviations. (nState x nEns)
%
% Ydev: Ye deviations for a single observation. (1 x nEns)
%
% w: A covariance localization for a single observation. (nState x 1)
%
% R: Uncertainty for a single observation. (1 x 1)
%
% ----- Outputs -----
%
% K: The kalman gain
%
% a: The alpha weight for the adjusted kalman gain for a serial update.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the coefficient for an unbiased estimator
nEns = size(Ydev,2);
unbias = 1 / (nEns-1);

% Get the numerator (localized covariance of M with Ye)
Knum = w .* unbias .* (Mdev * Ydev');

% Get the denominator. This is the uncertainty in the system. It is the Ye
% error covariance + observation uncertainty.
Kdenom = unbias .* (Ydev * Ydev') + R;

% Get the full Kalman gain
K = Knum / Kdenom;

% Get the alpha scaling factor
a = 1 / ( 1 + sqrt(R/Kdenom) );

end