function[Knum, Ycov] = estimateCovariance(kf, t, Mdev, Ydev)
%% Estimates the covariance of the proxy sites with 1. The state vector and 
% 2. the other proxy sites in a particular time step.

% Determine whether the prior is used to estimate covariance
usePrior = true;
if kf.setC || (kf.blendC && kf.weights(kf.whichCov(t),2)==0)
    usePrior = false;
end

% If the prior is not required, get the user-specified covariance
if ~usePrior
    Knum = kf.C(:, :, kf.whichCov(t));
    Ycov = kf.Ycov(:, :, kf.whichCov(t));
    
% Otherwise, using the prior. Get deviations if not provided
else
    if usePrior && (~exist('Mdev','var') || isempty(Mdev))
        M = kf.M(:, :, kf.whichPrior(t));
        [~, Mdev] = kf.decompose(M, 2);
    end
    if usePrior && (~exist('Ydev','var') || isempty(Ydev))
        Y = kf.Y(:, :, kf.whichPrior(t));
        [~, Ydev] = kf.decompose(Y, 2);
    end
    
    % Estimate covariance from the prior
    unbias = 1 / (kf.nEns - 1);
    Knum = unbias .* (Mdev * Ydev');
    Ycov = unbias .* (Ydev * Ydev');
    
    % Inflate
    if kf.inflateC
        Knum = kf.inflateFactor .* Knum;
        Ycov = kf.inflateFactor .* Ycov;
    end
    
    % Localize
    if kf.localizeC
        loc = kf.whichLoc(t);
        Knum = kf.w(:,:,loc) .* Knum;
        Ycov = kf.yloc(:,:,loc) .* Ycov;
    end
        
    % Blend
    if kf.blendC
        c = kf.whichCov(t);
        w = kf.weights(c,:);

        Knum = (w(1).*kf.C(:,:,c)) + (w(2).*Knum);
        Ycov = (w(1).*kf.Ycov(:,:,c)) + (w(2).*Ycov);
    end
end

end

