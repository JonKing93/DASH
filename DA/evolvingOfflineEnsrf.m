function[] = evolvingOfflineEnsrf(M, D, R, Y, whichPrior)
% Evolving offline EnSRF with a single set of covariance settings

% Sizes
[nState, nEns, nPrior] = size(M);
[nSite, nTime] = size(D);

% Preallocate
Amean = NaN(nState, 1, nTime);
Adev = NaN(nState, nEns, nTime);
calibRatio = NaN(nSite, nTime);

% Check if priors affect the covariance estimates
updateCovariance = checkCovariance;

% Get the time steps associated with each covariance estimate
if updateCovariance
    whichCov = whichPrior;
    nCov = nPrior;
else
    whichCov = ones(1, nTime);
    nCov = 1;
end

% Decompose ensembles.
[Mmean, Mdev] = decompose(M, 2);
[Ymean, Ydev] = decompose(Y, 2);
sites = ~isnan(D);

% Get the time step and priors associated with each covariance estimate
for c = 1:nCov
    times = find(whichCov==c);
    p1 = whichPrior(times(1));
    
    % Estimate the covariance
    [Knum, Ycov] = estimateCovariance(Mdev(:,:,p1), Ydev(:,:,p1));
    
    % Find the time steps that have the same observation sites and R values
    % (these will use the same Kalman Gain)
    gains = [sites(:,times); R(:,times)]';
    [gains, ~, whichGain] = unique(gains, 'rows');
    
    % Get the sites, time steps, and priors associated with each gain
    for g = 1:numel(gains)
        t = times(whichGain==g);
        t1 = t(1);
        s = sites(:, t1);
        
        % Calculate the Kalman Gain and adjusted gain
        Kdenom = kalmanDenominator(Ycov(s,s), R(s,t1));
        K = kalmanGain(Knum(:,s), Kdenom);
        Ka = kalmanAdjusted(Knum(:,s), Kdenom, R(s,t1));
        
        % Cycle through each prior with updates that use this gain. Get the
        % time steps that will be updated.
        [priors, ~, updatePrior] = unique( whichPrior(t) );
        for k = 1:numel(priors)
            p = priors(k);
            tu = t(updatePrior==k);
            
            % Update
            Am = updateMean( Mmean(:,:,p), K, D(s,tu), Ymean(s,:,p) );
            Amean(:,:,tu) = permute(Am, [1 3 2]);
            Adev(:,:,tu) = updateDeviations(Mdev(:,:,p), Ka, Ydev(s,:,p));
            
            % Calculations
            calibRatio(s,tu) = (D(s,tu) - Ymean(s,:,p)).^2 ./ diag(Kdenom);
            Q.calculate;
        end
    end
end

end