function[M] = ensrfUpdate(M, D, R, H)
%% Implements an EnSRF update for a dynamic model ensemble. Uses a
% vectorized version of EnSRF serial updates. Observational uncertainties
% are assumed to be Gaussian.
%
% A = ensrfUpdate(M, D, R, H)
% 
%
% ----- Inputs -----
%
% M: A model ensemble. Each column is the state vector for one model. (N x nEns)
%
% D: The vector of observations. (nObs x 1)
%
% R: The vector of observation uncertainties. (nObs x 1)
%
% H: The sampling matrix. A boolean/logical matrix for which each row
% records the index of a single observation. (nObs x N)
%
%
% ----- Outputs -----
%
% A: The updated model ensemble.
%
%
% ----- Written By -----
%
% Jonathan King, 2018, University of Arizona.

% Get the ensemble mean and deviations
Mmean = mean(M,2);
Mdev = M - Mmean;

% Get the observation estimates. Split into means and deviations. Also get
% their variance.
Y = H * M;
Ymean = mean(Y,2);
Ydev = Y - Ymean;
Yvar = var(Y,0,2);

% Get the Kalman Gain numerator. 
% (Covariance of the model ensemble errors with the estimate errors)
nEns = size(M,2);
unbias = 1 / (nEns-1);
Knum = unbias * Mdev * Ydev';

% Get the Kalman Gain denominator
% (Covariance of estimates + observation uncertainty)
Kdenom = Yvar + R;

% Get the Kalman Gain
K = Knum ./ Kdenom';

% Get the innovation vector
innov = D - Ymean;

% Update the means
Mmean = Mmean + K*innov;

% Calculate the scaling factors for the ensemble square root gain
alpha = 1 ./ (1 + sqrt( R./(Yvar + R) ) );

% Get the ensemble square root gain
K_ensrf = alpha' .* K;

% Update the deviations
Mdev = Mdev - K_ensrf * Ydev;

% Recover full field
M = Mmean + Mdev;

end