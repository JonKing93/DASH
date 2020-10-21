function[] = onlineFullBasicEnsrf(M, D, R, F, Q)
%% This is a skeleton for online, full EnSRF where the prior affects the
% covariance estimate and the covariance estimate does not also evolve over
% time.

% Sizes
[nSite, nTime] = size(D);
[nState, nEns] = size(M);
nCalcs = numel(Q);

% Preallocate
Amean = NaN(nState, nTime);
Adev = NaN(nState, nEns, nTime);
Y = NaN(nSite, nEns, nTime);

% Get the observation sites in each time step
for t = 1:nTime
    sites = find(~isnan(D(:,t)));
    
    % Make the estimates
    for k = 1:numel(sites)
        s = sites(k);
        if estimateR
            [Y(s,:,t), R(s,t)] = F{s}.estimate(M);
        else
            Y(s,:,t) = F{s}.estimate(M);
        end
    end
    
    % Decompose
    [Mmean, Mdev] = decompose(M);
    [Ymean, Ydev] = decompose(Y(sites,:,t));
    
    % Get the covariance estimates
    if dynamicLoc % This is a placeholder for future code implementing dynamic localization
        loc = dynamicLocalization(args);
    end
    [Knum, Ycov] = covarianceEstimate(Mdev, Ydev, loc);
    
    % Get the Kalman Gain
    Kdenom = kalmanDenominator(Ycov, R(sites,t));
    K = kalmanGain(Knum, Kdenom);
    Ka = kalmanAdjusted(Knum, Kdenom, R(sites,t));
    
    % Update
    Amean(:,t) = updateMean(Mmean, K, D(sites,t), Ymean);
    Adev(:,:,t) = updateDeviations(Mdev, Ka, Ydev);
    
    % Do calculations that require the deviations
    calibRatio(sites,t) = (D(sites,t) - Ymean).^2 ./ diag(Kdenom);
    for c = 1:nCalcs
        Q.calculate(Adev(:,:,t));
    end
    
    % Run the model forward one time step
    if propagateUpdates
        M = runModel(Amean(:,t) + Adev(:,:,t));
    else
        M = runModel(M);
    end
end

end