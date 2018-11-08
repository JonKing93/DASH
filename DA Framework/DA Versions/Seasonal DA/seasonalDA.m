function[A] = seasonalDA( M, D, R, Ye, YUpdate, H)
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
% D: A cell with observation data. The cell array should be formatted a
%   TS: This is the matrix of observation time series. (nObs x nTime)
%   coords: The (lat, lon) coordinates of each site. (nObs x 2)
%   stateVars: A logical array containing the indices of state variables needed
%             to run a forward model for a particular site. (nState x nObs)
%
% R: Observation uncertainty. (nObs x nTime)
%
% Rfix: Static observation uncertainty. (nObs x 1);
% 
% Ye: Model estimates of the observations. (nObs x nEns)
%
% H: A forward model used to calculate new model estimates from a state
%    vector ensemble.
%
% ----- Outputs -----
%
% A: Information on the updated model.
%
% ----- Written By -----
%
% Jonathan King, University of Arizona, 2018
%
% ----- Acknowledgements -----
%
% Steiger, Tardif, maybe Dee?

% Error-checking
% errorCheck();

% Get the weights for covariance adjustments.
w = covWeights( covArgs );

% Run the DA. Use different functions for different Ye updating schemes to
% optimize parallelization efficiency.
%
% Linear Ye updates. (Appended state, Tardif et al., 2018)
if strcmpi(YUpdate, 'linear')
    A = linearDA(M, Ye, D{1}, R, w);
    
% Full PSM Ye update
elseif strcmpi(YUpdate, 'full')
    A = fullDA(M, D{1}, D{3}, H, R, w);
    
% Vectorized EnSRF scheme. (No Ye update)
elseif strcmpi(YUpdate, 'vector')
    
    % For static R
    if rfixed
        A = vectorDAfixedR(M, Ye, D{1}, R, w);
        
    % Dynamic R
    else
        A = vectorDA(M, Ye, D{1}, R, w);
    end
end
        
end
