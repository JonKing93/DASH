function[K, a] = serialKalman( Mdev, Ydev, w, R )
%% Gets the kalman gain for serial updates
%
% [K, a] = dash.serialKalman( Mdev, ydev, w, R )
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

% Get the coefficient for an unbiased estimator
nEns = size(Ydev,2);
unbias = 1 / (nEns-1);

% Get the numerator, denominator (localized covariance of M with Ye)
Knum = unbias .* (Mdev * Ydev');
Knum = Knum .* w;
Kdenom = unbias .* (Ydev * Ydev') + R;

% Get the full Kalman gain and adjusted gain scaling factor
K = Knum / Kdenom;
a = 1 / ( 1 + sqrt(R/Kdenom) );

end