function[output] = serialENSRF( M, D, R, F, w )
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

% Decompose the initial ensemble. Clear the ensemble to free memory.
[Mmean, Mdev] = dash.decompose(M);
clearvars M;

% Preallocate
Amean = NaN( nState, nTime );
Avar = NaN( nState, nTime );
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
                [K, a] = dash.serialKalman( Ad, Ydev, w(:,d), R(d,t) );
                calibRatio(d,t) = ( D(d,t) - Ymean ).^2 ./ ( var(Ye(d,:,t)) + R(d,t) );
                
                % Update
                Am = Am + K*( D(d,t) - Ymean );
                Ad = Ad - (a * K * Ydev);    
            end
        end
    end
    
    % Record the mean and variance of the final analysis for the time step
    Amean(:,t) = Am;
    Avar(:,t) = sum( Ad.^2, 2 ) ./ (nEns - 1);
    progressbar(t/nTime);
end

% Create the output structure
output.settings = struct('Analysis', 'EnSRF', 'Type', 'Serial');
if ~all( w==1 )
    output.settings.Localize = w;
end
output.Amean = Amean;
output.Avar = Avar;
output.Ye = Ye;
output.calibRatio = calibRatio;
output.R = R;
output.sites = sites;

end