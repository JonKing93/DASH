function[M] = dhUpdate( M, D, R, H)
%% Implements the Dirren/Hakim method of data assimilation for time-averaged
% observations for a dynamic model ensemble. Uses an ensemble square root
% filter (EnSRF) for updates.
% 
%
% !!!!!!!!
% This method has some problems. 
%
% 1. For starters, it is very unclear how it compares for overlapping time
%    averages vs non-overlapping averages.
%
% 2. It requires all of the observations to use the same averaging period.
%    (Perhaps we could use ensrf serial updates for different averaging
%    periods?)
%    Alternatively, use an outside function to call dirren/Hakim multiple
%    times for each length of time average. (I think I like this better...)
%
% 3. This comment actually belongs in an outer function, but we should
% consider if time-propagation biases the output of an offline function
% to be improved forward in time. 
%
%
% ----- Inputs -----
%
% M: A 3D array of time-propagating model ensemble states. Each dim1 x dim2
% matrix is an ensemble of column state vectors at a point in time. Time (dim3)
% extends for the length of the observation averaging period. (N x nEns x tspan)
%
% D: A vector of time-averaged observations. (nObs x 1)
%
% R: The vector of observation error uncertainties. (nObs x 1)
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
% Jonathan King, 2018, University of Arizona

% Split the models into a time mean and deviations
Mmean = mean(M,3);
Mdev = M - Mmean;

% Update the time mean using an ensemble square root filter
Mmean = ensrfUpdate( D, R, Mmean, H);

% Add the updated means to the time deviations
M = Mmean + Mdev;

end