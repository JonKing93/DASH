function[Amean] = updateMean( Mmean, K, D, Ymean )
% Updates the ensemble mean in all time steps that have the same Kalman
% Gain.
%
% Amean = updateMean(Mmean, K, D, Ymean)
%
% ----- Inputs -----
%
% Mmean: The ensemble mean. (nState x nTime)
%
% K: The Kalman Gain (nState x nSite)
%
% D: The observations in the time steps (nSite x nTime)
% 
% Ymean: The mean of the Y estimates in each time step. (nSite x nTime)
%
% ----- Outputs -----
%
% Amean: The updated ensemble mean in each time step (nState x nTime)

Amean = Mmean + K * (D - Ymean);

end