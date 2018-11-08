function[A] = seasonalDA( M, D, R, Ye, loc, YUpdate, H, Dsite)
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

% For no covariance 
if strcmpi(adjustCov, 'none')
    % 

loc = covLocalization( D{2}, coords, rLoc )



% Run the DA. Use different functions for different Ye updating schemes to
% optimize parallelization efficiency.

% Linear Ye updates. (Appended state, Tardif et al., 2018)
if strcmpi(YUpdate, 'linear')
    A = linearDA(M, Ye, D{1}, R, loc);
    
% Full PSM Ye update
elseif strcmpi(YUpdate, 'full')
    A = fullDA(M, D{1}, D{3}, H, R, loc);
    
% Vectorized EnSRF scheme. (No Ye update)
elseif strcmpi(YUpdate, 'vector')
    
    % For static R
    if rfixed
        A = vectorDAfixedR(M, Ye, D{1}, R, loc);
        
    % Dynamic R
    else
        A = vectorDA(M, Ye, D{1}, R, loc);
    end
end
        
end


























% Decompose into ensemble mean and deviations
Mmean = mean(M,2);
Mdev = M - Mmean;

% Get the scaling factor for unbiased covariance calculations
unbias = 1 ./ (nEns-1);

% If vectorized...
if strcmpi(YUpdate, 'vector')
    
    % Decompose the model estimates
    Ymean = mean(Ye,2);
    Ydev = Y - Ymean;
    Yvar = var(Y,0,2);
    
    % Get the Kalman numerator
    Knum = unbias * Mdev * Ydev';
    Knum = loc .* Knum;
    
    % Get the innovation vector
    innov = D - Mmean;
    
    % If R is fixed...
    if rFixed
        
        % Get the adjusted gain for EnSRF
        Kdenom = Yvar + R;
        
        % Get the Kalman Gain
        K = Knum ./ Kdenom';
        
        % Calculate scaling factors for EnSRF
        alpha = 1 ./ (1 + sqrt(R ./ Kdenom) );
        
        % Get the adjusted gain
        Kadj = alpha' .* K;
    end
end

% For each time step
parfor t = 1:nTime
    
    % Get sliced variables
    
    
    
    
    
    
    
    

