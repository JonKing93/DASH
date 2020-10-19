function[] = evolvingOfflineEnsrf(M, D, R, Y, Q, returnMean, returnDevs)
%% Implements an ensemble square root Kalman filter for time steps with an
% evolving offline prior.

% Sizes
[nObs, nTime] = size(D);
[nState, nEns] = size(M);

% Preallocate
out = struct();
out.calibRatio = NaN(nObs, nTime);
if returnMean
    out.Amean = NaN(nState, 1, nTime);
end
if returnDevs
    out.Adev = NaN(nState, nEns, nTime);
end

% Determine if changing the prior will change the covariance estimates
updateCovariance = checkCovariance;

% If priors do not affect covariance, estimate once and update
if ~updateCovariance    
    [Knum, Ycov] = covarianceEstimate;
    [Am, Ad, cr] = ensrfConstantCovariance(M, Y, D, R, whichprior, Knum, Ycov);
    
    % Save
    out.Amean = Am;
    out.Adev = Ad;
    out.calibRatio = cr;
    
% If priors affect covariance, re-estimate for each prior
else
    for p = 1:nPrior
        [Knum, Ycov] = covarianceEstimate( M(:,:,p) );
    
        % Get the associated time steps and update
        t = find(whichprior==p);
        wp = ones(1, numel(t));
        [Am, Ad, cr] = ensrfConstantCovariance(M(:,:,p), Y(:,:,p), D(:,t), R(:,t), wp, Knum, Ycov);
        
        % Save
        out.Amean(:,:,t) = Am;
        out.Adev(:,:,t) = Ad;
        out.calibRatio(:,t) = cr;
    end
end

end