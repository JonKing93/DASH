function[] = evolvingOfflineEnsrf(M, D, R, Y, whichPrior)
% Implements an offline ensemble square-root Kalman Filter. Can use a
% static or evolving prior.
%
% output = offlineEnsrf(M, D, R, Y)
% Implements offline EnSRF for a static prior.
%
% output = offlineEnsrf(M, D, R, Y, whichPrior)
% Implements offline EnSRF for an evolving prior.
%
% ----- Inputs -----
%
% M: The model priors. A numeric array. If a static prior (nState x nEns). 
%    If an evolving prior (nState x nEns x nPrior).
%
% D: The observations. (nSite x nTime)
%
% R: Observation uncertainties. (nSite x nTime)
%
% Y: Observation model estimates. (nSite x nEns x nPrior)
%
% whichPrior: A vector of integers that indicates which prior to use in
%    each time step. Each element is the index of the prior in the third
%    dimension of M for a particular time step. (nTime x 1)
%
% ----- Outputs -----
%
% output: A structure containing output fields for the assimilation

% Sizes
[nState, nEns, ~] = size(M);
[nSite, nTime] = size(D);

% Preallocate
Amean = NaN(nState, 1, nTime);
Adev = NaN(nState, nEns, nTime);
calibRatio = NaN(nSite, nTime);

% Decompose ensembles. Note observation sites.
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