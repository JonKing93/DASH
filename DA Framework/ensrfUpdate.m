function[M] = ensrfUpdate( D, R, varargin)
% Implements an EnSRF update.
%
% For dynamic ensembles:
% A = ensrfUpdate( D, R, M, H)
%
% For static ensembles:
% A = ensrfUpdate( D, R, Mcell, Ycell, Knum )
% 
% which is equivalent to: 
% 
% A = ensrfUpdate( D, R, {Mmean, Mdev}, {Ymean, Ydev, Yvar}, Knum )
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

% If a dynamic ensemble, do the setup for the update
if nargin == 4
    [Mcell, Ycell, Knum] = kalmanSetup(varargin{1}, varargin{2});
else
    Mcell = varargin{1};
    Ycell = varargin{2};
    Knum = varargin{3};
end

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
alpha = 1 ./ (1 + sqrt( R ./ Kdenom ) );

% Get the ensemble square root gain
K_ensrf = alpha' .* K;

% Update the deviations
Mcell{2} = Mcell{2} - K_ensrf * Ycell{2};

% Recover full field
M = Mcell{1} + Mcell{2};

end