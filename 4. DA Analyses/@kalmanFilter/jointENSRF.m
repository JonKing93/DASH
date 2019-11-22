function[output] = jointENSRF( M, D, R, F, w, yloc, meanOnly, fullDevs )
%% Implements an ensemble square root kalman filter updating observations jointly
%
% [output] = dash.jointENSRF( M, D, R, F, w, yloc, meanOnly )
%
% ----- Inputs -----
%
% M: The model ensemble. (nState x nEns)
%
% D: The observations. (nObs x nTime)
%
% R: Observation uncertainty. NaN values will be determined via dynamic R
%    generation by the PSM. (nObs x nTime)
%
% F: A cell array of proxy system models of the "PSM" class. (nObs x 1)
%
% w: State vector - observation localization weights. (nState x nObs)
%
% yloc: Observation - observation localization weights (nObs x nObs)
%
% meanOnly: scalar logical.
%
% fullDevs: Whether to return full ensemble deviations. Scalar logical
%
% ----- Outputs -----
%
% output: A structure with the following fields
%
%   settings - The settings used to run the filter
%
%   Amean - The updated ensemble mean (nState x nTime)
%
%   Avar - Updated ensemble variance (nState x nTime)
%
%   Adev - Updated ensemble deviations (nState x nEns x nTime)
%
%   Ye - Proxy estimates (nObs x nEns)
%
%   calibRatio - The calibration ratio. (nObs x nTime)
%
%   R - The observation uncertainty used to run the filter. Includes
%       dynamically generated R values. (nObs x nTime).
%
%   sites - A logical array indicating which sites were used to update each
%           time step. (nObs x nTime)

% Get some sizes
[nObs, nTime] = size(D);
[nState, nEns] = size(M);

% Preallocate
Ye = NaN( nObs, nEns );
sites = false(nObs, nTime);
Amean = NaN(nState, nTime);
if fullDevs
    Adev = NaN( nState, nEns, nTime );
elseif ~meanOnly
    Avar = NaN( nState, nTime );
end
calibRatio = NaN( nObs, nTime );

% Generate the model estimates
for d = 1:nObs
    Mpsm = M(F{d}.H, :);    
    hasObs = ~isnan( D(d,:) );    
    [Ye(d,:), R(d,hasObs), sites(d,hasObs)] = dash.processYeR( F{d}, Mpsm, R(d,hasObs), NaN, d  );
end

% Compute the (static) Kalman numerator. Clear M for space
[Ymean, Ydev] = dash.decompose( Ye );
[Mmean, Mdev] = dash.decompose(M);
clearvars M;
Knum = kalmanFilter.jointKalman( 'Knum', Mdev, Ydev, w );

% Use the obs in each time step to compute the full kalman gain
progressbar(0);
for t = 1:nTime    
    sites(:,t) = sites(:,t) & ~isnan( D(:,t) );
    obs = sites(:,t);    
    [K, Kdenom] = kalmanFilter.jointKalman( 'K', Knum(:,obs), Ydev(obs,:), yloc(obs,obs), R(obs,t) );
    
    % Update the mean and get the calibration ratio
    Amean(:,t) = Mmean + K * ( D(obs,t) - Ymean(obs) );    
    calibRatio( obs, t ) = abs( D(obs,t) - Ymean(obs) ).^2 ./ ( diag(Kdenom) );

    % Optionally update the deviations / variance
    if ~meanOnly
        Ka = kalmanFilter.jointKalman( 'Ka', Knum(:,obs), Kdenom, R(obs,t) );
        if fullDevs
            Adev(:,:,t) = Mdev - Ka * Ydev(obs,:);
        else
            Avar(:,t) = sum(   (Mdev - Ka * Ydev(obs,:)).^2, 2) ./ (nEns-1);
        end
    end
                    
    progressbar(t/nTime);
end

% Create the output structure
output.settings = struct('Updates', 'Joint', 'Mean_Only', meanOnly);
if ~all(w==1, 'all') || ~all(yloc==1, 'all')
    output.settings.Localize = {w, yloc};
end 
output.Amean = Amean;
if fullDevs
    output.Adev = Adev;
    output.Amean = permute( Amean, [1 3 2] );
elseif ~meanOnly
    output.Avar = Avar;
end
output.Ye = Ye;
output.calibRatio = calibRatio;
output.R = R;
output.sites = sites;

end