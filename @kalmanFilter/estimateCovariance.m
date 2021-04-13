function[Knum, Ycov] = estimateCovariance(kf, t, Xdev, Ydev)
%% Returns the covariance estimate in a time step given the deviations of
% the prior and Y estimates
%
% [Knum, Ycov] = kf.estimateCovariance(t, Xdev, Ydev)
%
% ----- Inputs -----
%
% t: The index of a single time step.
%
% Xdev: The deviations of the prior
%
% Ydev: The deviations for the Y estimates
%
% ----- Outputs -----
%
% Knum: The Kalman numerator / covariance estimate between the state vector
%    and proxy sites
%
% Ycov: Covariances between proxy sites and one another

% If the covariance is set directly then load covariance directly
if kf.setCov
    Knum = kf.C(:,:, kf.whichCov(t));
    Ycov = kf.Ycov(:,:, kf.whichCov(t));
    
% Otherwise, estimate covariance from the deviations
else
    unbias = 1/(kf.nEns-1);
    Knum = unbias .* (Xdev * Ydev');
    Ycov = unbias .* (Ydev * Ydev');
    
    % Inflate
    if kf.inflateCov
        factor = kf.inflateFactor(kf.whichFactor(t));
        Knum = factor .* Knum;
        Ycov = factor .* Ycov;
    end
    
    % Localize
    if kf.localizeCov
        loc = kf.whichLoc(t);
        Knum = kf.wloc(:,:,loc) .* Knum;
        Ycov = kf.yloc(:,:,loc) .* Ycov;
    end
    
    % Blend
    if kf.blendCov
        cov = kf.whichCov(t);
        w = kf.blendWeights(cov,:);
        
        Knum = (w(1) .* kf.C(:,:,cov)) + (w(2) .* Knum);
        Ycov = (w(1) .* kf.Ycov(:,:,cov)) + (w(2) .* Ycov);
    end    
end

end