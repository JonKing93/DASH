function[A] = seasonalDA( M, D, R, Ye, loc, updateType, H, Dsite)
%% Performs static seasonal data assimilation. Targeted toward VS-Lite.
%
% A = seasonalDA(M, D, R, Ye, loc, 'linear')
% Processes observations serially. Appends model estimates to state vector
% and updates estimates via the Kalman Gain.
%
% A = seasonalDA(M, D, R, [], loc, 'full', H, Dsite)
% Processes observations serially. Re-calculates model estimates using a
% full forward model.
%
% A = seasonalDA( M, D, R, Ye, loc, 'vector' )
% Uses a vectorized EnSRF update. Model estimates are not updated.
%
% A = seasonalDA( M, D, Rfix, ... )
% Uses a static value for observation uncertainty. Allows further
% optimization for vectorized updates.
%
%
% ----- Inputs -----
%
% M: A static model ensemble state vector. (nState x nEns)
%
% D: Observations. (nObs x nTime)
%
% R: Observation uncertainty. (nObs x nTime)
%
% Rfix: Static observation uncertainty. (nObs x 1);
% 
% Ye: Model estimates of the observations. (nObs x nEns)
%
% loc: A covariance localization. (nState x nObs)
%
% H: A forward model used to calculate new model estimates from a state
%    vector ensemble.
%
% Dsite: A cell containing the indices in the state vector needed to run
%        the forward model at a node.  {nObs x 1}
%
%
% ----- Outputs -----
%
% A: Information on the updated model.
%
%
% ----- Written By -----
%
% Jonathan King, University of Arizona, 2018
%
%
% ----- Acknowledgements -----
%
% Steiger, Tardif, maybe Dee?