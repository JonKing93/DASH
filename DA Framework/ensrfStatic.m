function[M] = ensrfStatic( Mcell, Ycell, Knum, D, R)
% Implements an EnSRF update for a static model ensemble. Since a static
% ensemble is unchanging in time, ensemble means/deviations, Kalman
% numerators and estimate means/deviations/variance are fixed, and should
% be calculated outside of the function.
%
% A = ensrfStatic( {Mmean, Mdev}, {Ymean, Ydev, Yvar}, Knum, D, R )
%
%
% ----- Inputs -----
%
% Mmean: The model ensemble mean. (N x 1)
%
% Mdev: The model ensemble deviations (N x nEns)
%
% Ymean: The mean observation estimates (nObs x 1)
%
% Ydev: The observation estimate deviations (nObs x nEns)
%
% Yvar: The observation estimate variances (nObs x 1)
%
% Knum: The Kalman Gain numerator (N x nObs)
%
% D: The vector of observations. (nObs x 1)
%
% R: The vector of observation uncertainties. (nObs x 1)
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

% Get the Kalman Gain denominators for each time update
% (Covariance of estimates + observation uncertainty)
Kdenom = Ycell{3} + R;

% Get the Kalman Gain
K = Knum ./ Kdenom';

% Get the innovation vector
innov = D - Ycell{1};

% Update the means
Mcell{1} = Mcell{1} + K*innov;

% Calculate the scaling factors for the ensemble square root gain
alpha = 1 ./ (1 + sqrt( R./(Ycell{3} + R) ) );

% Get the ensemble square root gain
K_ensrf = alpha' .* K;

% Update the deviations
Mcell{2} = Mcell{2} - K_ensrf * Ycell{2};

% Recover full field
M = Mcell{1} + Mcell{2};

end