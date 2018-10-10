function[A] = dhUpdate( M, D, R, H)
%% Implements the Dirren / Hakim method for updating time-averages.
% Offline, EnSRF
% 
%
% !!!!!!!!
% This method has so many problems. 
%
% For starters, it is very unclear how it compares for overlapping time
% averages vs non-overlapping averages.
%
%
% ----- Inputs -----
%
% M: A time-propagating set of offline model states. (N x MC x t)
%
% D: A set of time-averaged observations
%
% R: Observational error uncertainties
%
% H: Sampling matrix for the observations
%
% tSpan: The number of time-steps to use for the time-averaging update

% Split the models into a time mean and deviations
M_tmean = mean(M,3);
M_tdev = M - M_tmean;

% Get the model estimates for mean observations
Y = H * M_tmean;

% Get the ensemble mean and deviations for the time mean.
ensMean = mean( M_tmean, 2);
ensDev = M_tmean - ensMean;

% Update the 
A_tmean = ensrfUpdate( ensMean, ensDev, Y, D, R);

% Add to the time deviations to get the complete update.
A = A_tmean + M_tdev;

end
