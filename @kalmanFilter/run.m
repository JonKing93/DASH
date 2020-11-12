function[out] = run(kf)


% Check that all essential inputs are provided
assert(~isempty(kf.M), 'You cannot run the Kalman filter because you have not provided a prior. (See the "prior" method)');
assert(~isempty(kf.D), 'You cannot run the Kalman filter because you have not provided observations. (See the "observations" method)');
assert(~isempty(kf.Y), 'You cannot run the Kalman filter because you have not provide model estimates of the proxies/observations. (See the "estimates" method).');
if isempty(kf.whichPrior)
    kf.whichPrior = ones(kf.nTime, 1);
end

% Determine whether to update the deviations
updateDevs = false;
if kf.return_devs || ~isempty(kf.Q)
    updateDevs = true;
end

% Preallocate
out = struct();
out.Amean = NaN(kf.nState, kf.nTime);
if kf.return_devs
    out.Adev = NaN(kf.nState, kf.nEns, kf.nTime);
end

% Preallocate quantities calculated from the posterior
out.calibRatio = NaN(kf.nSite, kf.nTime);
for q = 1:numel(kf.Q)
    name = kf.Q{q}.outputName;
    siz = kf.Q{q}.outputSize(kf.nState, kf.nTime, kf.nEns);
    out.(name) = NaN(siz);
end

% Decompose ensembles and note observations sites
[Mmean, Mdev] = kf.decompose(kf.M, 2);
[Ymean, Ydev] = kf.decompose(kf.Y, 2);
sites = ~isnan(kf.D);

% Find the number of unique covariance estimates. Get the time steps
% associated with each.
covSettings = kf.covarianceSettings;
[covSettings, ~, whichCov] = unique(covSettings, 'rows');
nCov = size(covSettings, 1);

% Make each covariance estimate. Get its associated time steps
for c = 1:nCov
    times = find(whichCov==c);
    p = kf.whichPrior(times(1));
    [Knum, Ycov] = kf.estimateCovariance(times(1), Mdev(:,:,p), Ydev(:,:,p));
    
    % Find the time steps that have the same observation sites and R
    % values. (These will have the same Kalman Gain)
    gains = [sites(:,times); kf.R(:,times)]';
    [gains, ~, whichGain] = unique(gains, 'rows');
    nGains = size(gains,1);
    
    % Get the sites, time steps, and priors associated with each gain
    for g = 1:nGains
        t = times(whichGain==g);
        s = sites(:, t(1));
        
        % Kalman Gain and adjusted Gain
        Rk = diag( kf.R(s,t(1)) );
        Kdenom = Ycov(s,s) + Rk;
        K = Knum(:,s) / Kdenom;
        if updateDevs
            Ksqrt = sqrtm(Kdenom);
            Ka = Knum(:,s) * (Ksqrt^(-1))' * (Ksqrt + sqrtm(Rk))^(-1);
        end
        
        % Cycle through each prior that has updates using this gain. Get
        % the time steps that will be updated for each prior.
        [priors, ~, updatePrior] = unique( kf.whichPrior(t) );
        for pk = 1:numel(priors)
            p = priors(pk);
            tu = t(updatePrior==pk);
            
            % Update
            Amean = Mmean(:,:,p) + K * (kf.D(s,tu) - Ymean(s,:,p));
            if updateDevs
                Adev = Mdev(:,:,p) - Ka * Ydev(s,:,p);
            end
            
            % Calculated quantities
            out.calibRatio(s,tu) = (kf.D(s,tu) - Ymean(s,:,p)).^2 ./ diag(Kdenom);
            for q = 1:numel(kf.Q)
                name = kf.Q{q}.outputName;
                td = kf.Q{q}.timeDim;
                
                indices = repmat({':'}, [1 td]);
                indices(td) = {tu};
                out.(name)(indices{:}) = kf.Q{q}.calculate(Adev, Amean);
            end
        end
    end
end

end