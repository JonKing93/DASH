function[output] = serialENSRF( M, D, R, F, w, fullDevs, percentiles )
%% Implements an ensemble square root kalman filter with serial updates.
%
% [output] = dash.serialENSRF( M, D, R, F, w )
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
% w: Covariance localization weights. (nState x nObs)
%
% percentiles: A vector of values between 0 and 100 specifying which
%              percentiles to return. (nPerc x 1)
%
% fullDevs: Scalar logical indicating whether to return full ensemble
%           deviations.
%
% ----- Outputs -----
%
% output: A structure with the following fields
%
%   settings - The settings used to run the filter
%
%   Amean - The updated ensemble mean (nState x nTime)
%
%   Adev - Updated ensemble deviations (nState x nEns x nTime)
%
%   Avar - Updated ensemble variance (nState x nTime)
%
%   Aperc - Percentiles of the updated ensemble. (nState x nPerc x nTime)
%
%   Ye - Proxy estimates (nObs x nEns x nTime)
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
nPerc = numel( percentiles );

% Decompose the initial ensemble. Clear the ensemble to free memory.
[Mmean, Mdev] = dash.decompose(M);
clearvars M;

% Preallocate
Amean = NaN( nState, nTime );
if fullDevs
    Adev = NaN( nState, nEns, nTime );
else
    Avar = NaN( nState, nTime );
end
Aperc = NaN( nState, nPerc, nTime );
Ye = NaN( nObs, nEns, nTime );
sites = false( nObs, nTime );
calibRatio = NaN( nObs, nTime );

% Initialize each time step with the prior
progressbar(0);
for t = 1:nTime    
    Am = Mmean;
    Ad = Mdev;    
    
    % Estimate Ye for each observation in this time step
    for d = 1:nObs
        if ~isnan( D(d,t) )
            Mpsm = Am(F{d}.H) + Ad(F{d}.H,:);                           
            [Ye(d,:,t), R(d,t), sites(d,t)] = dash.processYeR( F{d}, Mpsm, R(d,t), t, d );
            
            % If Ye and R were successful, use to update
            if sites(d,t)
                
                % Decompose the estimates, get the Kalman gain, and
                % calibration ratio
                [Ymean, Ydev] = dash.decompose( Ye(d,:,t) );
                [K, a] = kalmanFilter.serialKalman( Ad, Ydev, w(:,d), R(d,t) );
                calibRatio(d,t) = ( D(d,t) - Ymean ).^2 ./ ( var(Ye(d,:,t)) + R(d,t) );
                
                % Update
                Am = Am + K*( D(d,t) - Ymean );
                Ad = Ad - (a * K * Ydev);    
            end
        end
    end
    
    % Record the updated mean and variance/deviations for the time step
    Amean(:,t) = Am;
    if fullDevs
        Adev(:,:,t) = Ad;
    else
        Avar(:,t) = sum( Ad.^2, 2 ) ./ (nEns - 1);
    end
    if nPerc > 0
        Aperc(:,:,t) = Am + prctile( Ad, percentiles, 2 );
    end
    progressbar(t/nTime);
end

% Create the output structure
output.settings = struct('Analysis', 'EnSRF', 'Type', 'Serial','version', dash.version, 'Time_Completed', datetime(clock));
if ~all( w==1, 'all' )
    output.settings.Localize = w;
end
output.Amean = Amean;
if fullDevs
    output.Adev = Adev;
    output.Amean = permute( Amean, [1 3 2] );
else
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