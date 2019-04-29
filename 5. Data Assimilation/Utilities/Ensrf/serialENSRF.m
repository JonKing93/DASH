function[Amean, Avar, Ye, update] = serialENSRF( M, D, R, F, w )
%% Implements data assimilation using an ensemble square root filter with serial
% updates for individual observations. Time steps are assumed independent
% and processed in parallel.
%
% [A, Y] = dashDA( M, D, R, F, w )
% Performs data assimilation.
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
% w: Covariance localization weights. (nState x nObs)
%
% F: An array of proxy system models of the "PSM" class. One model for each
%      observation. (nObs x 1)
%
% ----- Outputs -----
%
% A: The mean and variance of the analysis ensemble. (nState x nTime x 2)
%
% Y: The model estimates used for each update. (nObs x nEns x nTime)

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get some sizes
[nObs, nTime] = size(D);
[nState, nEns] = size(M);

% Decompose the initial ensemble. Clear the ensemble to free memory.
[Mmean, Mdev] = decomposeEnsemble(M);
clearvars M;

% Preallocate the output
Amean = NaN( nState, nTime );
Avar = NaN( nState, nTime );
Ye = NaN( nObs, nEns, nTime );

% Preallocate an array to track which PSMs were used to update
update = false( nObs, nTime );

% Each time step is independent, process in parallel
parfor t = 1:nTime
    
    % Initialize the update for this time step
    Am = Mmean;
    Ad = Mdev;    
    
    % For each observation that is not a NaN
    for d = 1:nObs
        if ~isnan( D(d,t) )
            
            % Get the model elements to pass to the PSM
            Mpsm = Am(F{d}.H) + Ad(F{d}.H,:);                   %#ok<PFBNS>
            
            % Run the PSM. Generate R. Error check.
            [Ye(d,:,t), R(d,t), update(d,t)] = getPSMOutput( F{d}, Mpsm, R(d,t), t, d ); %#ok<PFOUS>
            
            % If no errors occured in the PSM, and the R value is valid,
            % update the analysis
            if update(d,t)
                
                % Decompose the model estimate
                [Ymean, Ydev] = decomposeEnsemble( Ye(d,:,t) );

                % Get the Kalman gain and alpha scaling factor
                [K, a] = kalmanENSRF( Ad, Ydev, w(:,d), 1, R(d,t) );   %#ok<PFBNS>

                % Update
                Am = Am + K*( D(d,t) - Ymean );
                Ad = Ad - (a * K * Ydev);    
            end
        end
    end
    
    % Record the mean and variance of the final analysis for the time step
    Amean(:,t) = Am;
    Avar(:,t) = var( Ad, 0 ,2 );
end

end