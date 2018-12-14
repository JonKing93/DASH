function[A] = seasonalDA( M, Ye, D, R, covArgs, updateType, H)
%% Performs static seasonal data assimilation. Targeted toward VS-Lite.
%
% A = seasonalDA(M, Ye, D, R, covArgs, 'linear')
% Processes observations serially. Appends model estimates to state vector
% and updates estimates via the Kalman Gain.
%
% A = seasonalDA(M, meta, D, R, covArgs, F, H)
% Processes observations serially. Re-calculates model estimates using a
% full forward model.
%
% A = seasonalDA( M, Ye, D, R, covArgs, 'vector' )
% Uses a vectorized EnSRF update. Model estimates are not updated.
%
% A = seasonalDA( M, Ye, D, Rfix, covArgs, 'vector' )
% Uses a static value for observation uncertainty. Allows further
% speed increases for vectorized updates.
%
%
% ----- Inputs -----
%
% M: A static model ensemble state vector. (nState x nEns)
%
% Ye: Model estimates of the observations. (nObs x nEns)
%
% meta: A structure with metadata for the PSM. Must contain two fields:
%    coords: An array of coordinates for each state variable. (nState x nAxes)
%    time: A vector with the date of each observation. (nTime x 1) 
%
% D: Observations. (nSite x nTime)
%
% R: Observation uncertainty. (nObs x nTime)
%
% Rfix: Constant observation uncertainty. (nObs x 1)
%
% covArgs: Inputs used to calculate covariance weights.
%    
%
% F: A forward model of the "PSM" class.
%
% H: A cell with the indices needed to run the PSM at each time step.
%      time step. Each site may use multiple state variables to run the
%      forward model. {nSite x 1}
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
% !!!! Write this

% Error-checking
% errorCheck();

% Set the toggle for a full update
if isa(updateType, 'PSM')
    F = updateType;
    updateType = 'full';
    meta = Ye;
end

% Get the weights for covariance adjustments.
% w = covWeights( covArgs );
% The covariance localization isn't finished, so just stick with
% scalar values for now
w = 1;

% Linear Ye updates. (Appended state, Tardif et al., 2018)
if strcmpi(updateType, 'linear')
    A = linearDA(M, Ye, D, R, w);
    
% Full PSM Ye update
elseif strcmpi(updateType, 'full')
    A = fullDA(M, meta, D, R, H, F, w);
    
% Vectorized EnSRF scheme. (No Ye update)
elseif strcmpi(YUpdate, 'vector')
    
    % If R is not fixed
    if size(R) == size(D)
        A = vectorDA(M, Ye, D, R, w);
        
    % Otherwise, it is fixed
    else
        A = vectorDAfixedR(M, Ye, D, R, w);
    end

end
        
end
