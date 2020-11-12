function[Knum, Ycov] = estimateCovariance(kf, t, Mdev, Ydev)
%% Estimates the covariance of the proxy sites with 1. The state vector and 
% 2. the other proxy sites in a particular time step.

% Require a prior. (Can't set a covariance until specifying a prior). Get its index
assert(~isempty(kf.M), 'You must specify a prior before you can estimate covariance');
if kf.nTime==0 || isempty(kf.whichPrior)
    p = 1;
else
    assert(isnumeric(t) && isscalar(t), 't must be a numeric scalar');
    assert(ismember(t, 1:kf.nTime), sprintf('t must be the index of a time step. It must be an integer on the interval [1, %.f]', kf.nTime));
    p = kf.whichPrior(t);
end

% User-specified covariance
if kf.setCov
    Knum = kf.C(:, :, kf.whichCov(t));
    Ycov = kf.Ycov(:, :, kf.whichCov(t));
    
% Otherwise, using the prior. Get deviations if not provided
else
    if ~exist('Mdev','var') || isempty(Mdev)
        [~, Mdev] = kf.decompose(kf.M(:,:,p), 2);
    end
    if ~exist('Ydev','var') || isempty(Ydev)
        [~, Ydev] = kf.decompose(kf.Y(:,:,p), 2);
    end
    
    % Estimate covariance from the prior
    unbias = 1 / (kf.nEns - 1);
    Knum = unbias .* (Mdev * Ydev');
    Ycov = unbias .* (Ydev * Ydev');
    
    % Inflate
    if kf.inflateCov
        Knum = kf.inflateFactor .* Knum;
        Ycov = kf.inflateFactor .* Ycov;
    end
    
    % Localize
    if kf.localizeCov
        loc = kf.whichLoc(t);
        Knum = kf.wloc(:,:,loc) .* Knum;
        Ycov = kf.yloc(:,:,loc) .* Ycov;
    end
        
    % Blend
    if kf.blendCov
        c = kf.whichCov(t);
        w = kf.weights(c,:);

        Knum = (w(1).*kf.C(:,:,c)) + (w(2).*Knum);
        Ycov = (w(1).*kf.Ycov(:,:,c)) + (w(2).*Ycov);
    end
end

end
