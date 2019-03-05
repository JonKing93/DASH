function[Amean, Avar, Ye] = serialENSRF( M, D, R, F, w )
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

% Each time step is independent, process in parallel
for t = 1:nTime
    
    % Slice variables to minimize parallel overhead.
    tD = D(:,t);
    tR = R(:,t);
    Ycurr = NaN(nObs, nEns);
    
    % Initialize the update for this time step
    Am = Mmean;
    Ad = Mdev;    
    
    % For each observation that is not a NaN and has an R value
    for d = 1:nObs
        if ~isnan(tD(d))
            
            % Get the model elements to pass to the PSM
            Mpsm = Am(F{d}.H) + Ad(F{d}.H,:);
            
            % Run the PSM. Generate R. Error check.
            [Ycurr(d,:), tR(d), update] = getPSMOutput( F{d}, Mpsm, tR(d), d, t );
            
            % If no errors occured in the PSM, and the R value is valid,
            % update the analysis
            if update && ~isnan(tR(d))

                % Decompose the model estimate
                [Ymean, Ydev] = decomposeEnsemble( Ycurr(d,:) );

                % Get the Kalman gain and alpha
                [K, a] = kalmanENSRF( Ad, Ydev, tR(d), w(:,d), 1 );                

                % Update
                Am = Am + K*( tD(d) - Ymean );
                Ad = Ad - (a * K * Ydev);    
            end
        end
    end   % End serial updates
    
    % Record the Y estimates for this time step.
    Ye(:,:,t) = Ycurr;
    
    % Record the mean and variance of the analysis.
    Amean(:,t) = Am;
    Avar(:,t) = var( Ad, 0 ,2 );
end

end