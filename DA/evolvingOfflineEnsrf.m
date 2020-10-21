function[] = evolvingOfflineEnsrf(M, D, R, Y, whichPrior)
% Evolving offline EnSRF with a single set of covariance settings

% Sizes
[nState, nEns, ~] = size(M);
[nSite, nTime] = size(D);

% Preallocate
Amean = NaN(nState, 1, nTime);
Adev = NaN(nState, nEns, nTime);
calibRatio = NaN(nSite, nTime);

% Decompose ensembles. Mark observation sites.
[Mmean, Mdev] = decompose(M, 2);
[Ymean, Ydev] = decompose(Y, 2);
sites = ~isnan(D);

% Get the time steps associated with each covariance estimate
covSettings = obj.covarianceSettings;
[covSettings, ~, whichCov] = unique(covSettings, 'rows');
nCov = size(covSettings,1);

% Make each covariance estimate. Get the associated time steps
for c = 1:nCov
    [Knum, Ycov] = estimateCovariance(Mdev, Ydev, covSettings(c,:));
    times = find(whichCov==c);
    
    % Find the time steps that have the same observation sites and R values
    % (these will use the same Kalman Gain)
    gains = [sites(:,times); R(:,times)]';
    [gains, ~, whichGain] = unique(gains, 'rows');
    
    % Get the sites, time steps, and priors associated with each gain
    for g = 1:numel(gains)
        t = times(whichGain==g);
        s = sites(:, t(1));
        
        % Calculate the Kalman Gain and adjusted gain
        Kdenom = kalmanDenominator(Ycov(s,s), R(s,t(1)));
        K = kalmanGain(Knum(:,s), Kdenom);
        Ka = kalmanAdjusted(Knum(:,s), Kdenom, R(s,t(1)));
        
        % Cycle through each prior with updates that use this gain. Get the
        % time steps that will be updated.
        [priors, ~, updatePrior] = unique( whichPrior(t) );
        for k = 1:numel(priors)
            p = priors(k);
            tu = t(updatePrior==k);
            
            % Update
            Am = Mmean(:,:,p) + K * (D(s,tu) - Ymean(s,:,p));
            Amean(:,:,tu) = permute(Am, [1 3 2]);
            Adev(:,:,tu) = Mdev(:,:,p) - Ka * Ydev;
            
            % Calculations
            calibRatio(s,tu) = (D(s,tu) - Ymean(s,:,p)).^2 ./ diag(Kdenom);
            Q.calculate;
        end
    end
end

end