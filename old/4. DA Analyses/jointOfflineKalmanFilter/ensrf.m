function[output] = ensrf( M, D, R, Y, ... % Basic inputs
                          inflate, w, yloc, Knum_clim, Ycov_clim, b,... % Covariance calculations
                          Q, percentiles, ... % Posterior calculations
                          returnMean, returnVar, returnDevs, ...  % Returned output
                          showProgress ) % Batch options
%% Runs an offline ensemble square root Kalman filter that processes all
% observations jointly.
%
% output = ensrf( M, D, R, Y, inflate, w, yloc, Knum_clim, Ycov_clim, Q,
%                 percentiles, returnMean, returnVar, returnDevs, showProgress )
%
% ----- Inputs -----
%
% M: Prior model ensemble (nState x nEns)
%
% D: Observations (nObs x nTime)
%
% R: Observation uncertainty (nObs x nTime)
%
% Y: Observation estimates (nObs x nEns)
%
% inflate: An inflation factor. A positive scalar. Use [] for no inflation.
%
% w: Observation-ensemble covariance localization weights (nState x nObs).
%    Use [] for no localization.
%
% yloc: Observation estimate covariance localization weights (nObs x nObs).
%       Use [] for no localization.
%
% Knum_clim: Climatological model-observation estimate covariance used for
%            blending covariance. (nState x nObs) Use [] for no blending.
%
% Ycov_clim: Climatological estimate-estimate covariance. (nObs x nObs) 
%            Use [] for no blending.
% 
% Q: Calculators for the posterior ensemble. (nCalcs x 1)
%    Use [] for no calculations.
%
% percentiles: The ensemble percentiles to return. A vector of values
%              between 0 and 100. (nPercs x 1)
%
% returnMean: Whether to return the updated ensemble mean as output. Scalar
%             logical.
%
% returnVar: Whether to return the variance of the updated ensemble as
%            output. A scalar logical.
%
% returnDevs: Whether to return the updated ensemble deviations as output.
%             A scalar logical.
%
% showProgress: Whether to display a progress bar. Scalar logical.
%
% ----- Output -----
%
% output: A structure that may contain the following fields
%
%   calibRatio: Calibration ratios for the observations (nObs x nTime)
%
%   Amean: The updated ensemble mean (nState x nTime)
%
%   Avar: The variance of the updated ensemble (nState x nTime)
%
%   Aperc: The percentiles of the updated ensemble (nState x nPercentile x nTime)
%
%   Adev: The updated ensemble deviations (nState x nEns x nTime)

% Decompose the ensembles
[Mmean, Mdev] = dash.decompose(M);
[Ymean, Ydev] = dash.decompose(Y);

% Get covariance matrices for the Kalman Gain
[Knum, Ycov] = ensrfCovariance( Mdev, Ydev, inflate, w, yloc, Knum_clim, Ycov_clim, b );

% Do the updates
output = ensrfUpdates( Mmean, Mdev, D, R, Ymean, Ydev, Knum, Ycov, Q,...
                       percentiles, returnMean, returnVar, returnDevs, showProgress );
                   
end