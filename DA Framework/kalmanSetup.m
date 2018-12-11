function[Mcell, Ycell, Knum] = kalmanSetup( M, H )
%% Does the first half of the Kalman Update calculations. Split from the
% actual update to enable both static and dynamic ensembles.
%
% [Mcell, Ycell, Knum] = kalmanSetup(M, H)
%
%
% ----- Inputs -----
%
% % M: A matrix of model ensemble states. Each dim1 x dim2
% matrix is an ensemble of column state vectors at a point in time. Time (dim3)
% extends for the length of the observation averaging period. (N x nEns)
%
% H: The sampling matrix. A boolean/logical matrix for which each row
% records the index of a single observation. (nObs x N)
%
%
% ----- Outputs -----
%
% Mcell: A cell containing the model ensemble mean and deviations {Mmean, Mdev}
%
% Ycell: A cell containing the ensemble estimate mean, deviations, and
% variance {Ymean, Ydev, Yvar}
%
% Knum: The numerator for the Kalman gain matrix.
%
%
% ----- Written By -----
%
% Jonathan King, 2018, University of Arizona

% Split the model into means and deviations
Mmean = mean(M,2);
Mdev = M - Mmean;

% Get the model estimates
Y = H*M;

% Get estimate means, deviations, and variance
Ymean = mean(Y,2);
Ydev = Y - Ymean;
Yvar = var(Y,0,2);

% Get the Kalman numerator
nEns = size(M,2);
unbias = 1 / (nEns-1);
Knum = unbias * Mdev * Ydev';

% Get output cells
Mcell = {Mmean, Mdev};
Ycell = {Ymean, Ydev, Yvar};

end