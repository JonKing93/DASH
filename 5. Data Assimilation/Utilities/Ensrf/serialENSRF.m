function[A, Y] = serialENSRF( M, D, R, F, w )
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
%    !!!!! Need to implement a more general R calculation
%
% w: Covariance localization weights. (nState x nObs)
%      !!! Could this be dynamic?
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
    
    % Slice variables to minimize parallel overhead. Preallocate Ye for the
    % time step to slice Ye output.
    tD = D(:,t);
    tR = R(:,t);
    Ycurr = NaN(nObs, nEns);
    
    % Initialize the update for this time step
    Amean = Mmean;
    Adev = Mdev;    
    
    % For each observation that is not a NaN
    for d = 1:nObs
        if ~isnan(tD(d))
            
            % Get the model elements to pass to the PSM
            Mpsm = Amean(F{d}.H) + Adev(F{d}.H,:);
            
            % Run the PSM. Optionally get R from the PSM. Check if the PSM
            % ran successfully and the analysis should be updated.
            [Ye, tR(d), update] = getPSMOutput( F{d}, Mpsm, d, t, tR(d) );
            
            % If no errors occured in the PSM, update the analysis
            if update

                % Decompose the model estimate
                [Ymean, Ydev] = decomposeEnsemble( Ye );

                % Get the Kalman gain and alpha
                [K, a] = kalmanENSRF( Adev, Ydev, tR(d), w(:,d));                

                % Update
                Amean = Amean + K*( tD(d) - Ymean );
                Adev = Adev - (a * K * Ydev);

                % Record Y if desired as output
                if recordYe
                    Ycurr(d,:) = Ye;
                end     
            end
        end
    end
    
    % Record the Y estimates for this time step.
    if recordYe
        Y(:,:,t) = Ycurr;
    end
    
    % Record the mean and variance of the analysis.
    Avar = var( Adev, 0, 2 );
    A(:,t,:) = [Amean, Avar];
end

end