function[Amean, Avar, Ye] = jointENSRF( M, D, R, F, w )
%% Does data assimilation using the Ensemble square root method (ENSRF).
% Runs all observations jointly. Does not use serial updates.

% Get some sizes
[nObs, nTime] = size(D);
[nState, nEns] = size(M);

% Preallocate the output
Amean = NaN(nState, nTime);
Avar = NaN(nState, nTime);
Ye = NaN(nObs, nEns);

% Keep track of 

% Precalculate Ye for time-independent PSMs.
for d = 1:nObs
    if ~F{d}.timeDependent
    
        % Get the model values to pass to the PSM
        Mpsm = Mmean(F{d}.H) + Mdev(F{d}.H,:);
    
        % Run the PSM
        [Ye(d,:), R(d,:), update] = getPSMOutput( F{d}, Mpsm, d, R(d,:) )


% Decompose the initial ensemble
[Mmean, Mdev] = decomposeEnsemble(M);
clearvars M;

% Each time step is independent. Process in parallel
for t = 1:nTime
    
    % Slice observations. Get values that are non NaN
    tD = D(:,t);
    obs = ~isnan(tD);
    
    % Slice the R values and Ye output.
    tR = R(:,t);
    Ycurr = NaN(nObs, nEns);
    
    % For each observation that is not NaN
    for d = 1:nObs
        if obs(d)
        
            % Get the model elements needed to run the PSM

            % Run the PSM
            [Ycurr(d,:), tR(d), update] = getPSMOutput( F{d}, Mpsm, d, t, tR(d) );
            
            % Remove the observation if the PSM failed
            if ~update
                obs(d) = false;
            end
        end
    end
    
    % Decompose the model estimates for the observations
    [Ymean, Ydev] = decomposeEnsemble( Ycurr(obs,:) );
    
    % Convert R to a diagonal matrix
    tR = diag( tR(obs) );
    
    % Get the kalman gain and adjusted gain
    error('Covariance localization is broken.');
    [K, Khat] = kalmanENSRF( Adev, Ydev, tR, w(:,obs) );
    
    % Update. Save mean, variance, and Ye
    Amean(:,t) = Mmean + K*( tD(obs) - Ymean );
    Avar(:,t) = var(   Mdev - Khat * Ydev,   0, 2 );
    Ye(:,:,t) = Ycurr;
end

end
    