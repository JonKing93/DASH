function[output] = ensrfUpdates( Mmean, Mdev, D, R, Ymean, Ydev, ... 
                                 Knum, Ycov, ...
                                 Q, percentiles, ...
                                 returnMean, returnVar, returnDevs, ...
                                 showProgress )

% Preallocate output. Determine whether to calculate mean and deviations.
[nObs, nTime] = size(D);
[nState, nEns] = size(Mdev);
nPercs = numel(percentiles);
nCalcs = numel(Q);
[output, calculateMean, calculateDevs] = preallocateENSRF( nObs, nTime, ...
    nState, nEns, nPercs, nCalcs, returnMean, returnVar, returnDevs );

% Get the unique sets of obs + R for the various time steps (each set has
% a unique Kalman Gain)
hasobs = ~isnan(D);
obsR = [hasobs;R]';
[~, iA, iC] = unique( obsR, 'rows' );
nSet = numel(iA);

% Progress bar
if showProgress
    progressbar(0);
end

% Get the time steps, obs, and R for each set
for k = 1:nSet
    t = find(iC==k);
    nt = numel(t);   % Numer of time steps in the set
    obs = hasobs(:, t(1));
    Rset = R(obs, t(1));
    
    % Get the Kalman Gain
    Kdenom = kalmanDenominator( Ycov(obs,obs), Rset );
    K = kalmanGain( Knum(:,obs), Kdenom );
    
    % Update the mean
    if calculateMean
        Amean = updateMean( Mmean, K, D(obs,t), Ymean(obs) );
    end
    
    % Calibration ratio
    output.calibRatio(obs,t) = calibrationRatio( D(obs,t), Ymean(obs), Kdenom );
    
    % Update the deviations
    if calculateDevs
        Ka = kalmanAdjusted( Knum(:,obs), Kdenom, Rset );
        Adev = updateDeviations( Mdev, Ka, Ydev(obs,:) );
    end
    
    % Save mean
    if returnMean
        output.Amean(:,t) = Amean;
    end
    
    % Save variance
    if returnVar
        Avar = sum(Adev.^2, 2) ./ (nEns-1);
        output.Avar(:,t) = repmat( Avar, [1,nt] );
    end
    
    % Save deviations
    if returnDevs
        output.Adev(:,:,t) = repmat( Adev, [1,1,nt]);
    end
    
    % Posterior calculations
    if ~isempty(Q)
        output.calcs(:,:,t) = posteriorCalculations( Amean, Adev, Q );
    end
    
    % Ensemble percentiles
    if ~isempty(percentiles)
        Amean = permute(Amean, [1 3 2]);
        Aperc = prctile( Adev, percentiles, 2 );
        output.Aperc(:,:,t) = Amean + Aperc;
    end
    
    % Progress bar
    if showProgress
        progressbar(k/nSet);
    end
end

end