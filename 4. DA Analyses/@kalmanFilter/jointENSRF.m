function[output] = jointENSRF( M, D, R, F, w, yloc, meanOnly, fullDevs, percentiles, reconstruct )
%% Implements an ensemble square root kalman filter updating observations jointly
%
% [output] = dash.jointENSRF( M, D, R, F, w, yloc, meanOnly, fullDevs, percentiles, reconstruct )
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
% meanOnly: Whether to only update the ensemble mean. Scalar logical.
%
% fullDevs: Whether to return full ensemble deviations. Scalar logical
%
% percentiles: Which percentiles to return. A vector of values between 0
%              and 100 (nPerc x 1)
%
% reconstruct: Logical vector indicating which state vector elements to
%              reconstruct. (nState x 1)
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
%   Aperc - Percentiles of the updated ensemble. (nState x nPercentile x nTime)
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

% Get sizes
[nObs, nTime] = size(D);
nPerc = numel( percentiles );
nEns = size(M,2);

% Preallocate PSM outputs and calibration ratio
Ye = NaN( nObs, nEns );
sites = false(nObs, nTime);
calibRatio = NaN( nObs, nTime );

% Generate model estimates
for d = 1:numel(F)
    Mpsm = M(F{d}.H, :);    
    hasObs = ~isnan( D(d,:) );    
    [Ye(d,:), R(d,hasObs), sites(d,hasObs)] = dash.processYeR( F{d}, Mpsm, R(d,hasObs), NaN, d  );
end

% Reduce M to reconstructed elements. Get state vector length
M = M( reconstruct, : );
nState = size(M, 1);

% Preallocate updated ensemble
Amean = NaN(nState, nTime);
if fullDevs
    Adev = NaN( nState, nEns, nTime );
elseif ~meanOnly
    Avar = NaN( nState, nTime );
end
Aperc = NaN( nState, nPerc, nTime );

% Get (static) Kalman numerator. Clear M for space
[Mmean, Mdev] = dash.decompose( M );
clearvars M;
[Ymean, Ydev] = dash.decompose( Ye );
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

    % Optionally update the deviations / variance / percentiles
    if ~meanOnly
        Ka = kalmanFilter.jointKalman( 'Ka', Knum(:,obs), Kdenom, R(obs,t) );
        if fullDevs
            Adev(:,:,t) = Mdev - Ka * Ydev(obs,:);
            if nPerc > 0
                Aperc(:,:,t) = Amean(:,t) + prctile( Adev(:,:,t), percentiles, 2 );
            end
        elseif nPerc == 0
            Avar(:,t) = sum(   (Mdev - Ka * Ydev(obs,:)).^2, 2) ./ (nEns-1);
        else
            Adev = Mdev - Ka * Ydev(obs,:);
            Avar(:,t) = sum( Adev.^2, 2 ) ./ (nEns-1);
            Aperc(:,:,t) = Amean(:,t) + prctile( Adev, percentiles, 2 );
        end
    end
                    
    progressbar(t/nTime);
end

% Create the output structure
output.settings = struct('Updates', 'Joint', 'Mean_Only', meanOnly, 'version', dash.version, 'Time_Completed', datetime(clock));
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
if nPerc > 0
    output.settings.percentiles = percentiles(:)';
    output.Aperc = Aperc;
end
output.Ye = Ye;
output.calibRatio = calibRatio;
output.R = R;
output.sites = sites;

end