function[] = staticEnsrf(M, D, R, Y, Q, returnMean, returnDevs)
%% Implements an ensemble square root Kalman Filter for time steps with a
% static prior.
%
% ----- Inputs -----
%
% M: A model ensemble. (nState x nEns)
%
% D: Observations. (nSite x nTime)
%
% R: Observation uncertainties. (nSite x nTime)
%
% Y: Model estimates of observations. (nSite x nEns)
%
% Q: Calculations that require ensemble deviations
%
% returnMean: Scalar logical. Whether to return the updated ensemble mean.
%
% returnDevs: Scalar logical. Whether to return the updated ensemble deviations.

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

% Decompose the ensembles
[Mmean, Mdev] = decompose(M);
[Ymean, Ydev] = decompose(Y);

% Get the covariance estimates
[Knum, Ycov] = covarianceEstimate;

% Get the sets of time steps with the same Kalman Gain. (Those with the
% same observation sites and R values)
sites = ~isnan(D);
gains = [sites; R]';
[~, iA, iC] = unique(gains, 'rows');

% Get each set of time steps with a constant gain and the associated sites
for k = 1:numel(iA)
    t = find(iC==k);
    s = sites(:, t(1));
    
    % Update
    [Amean, Adev, calibRatio] = ensrfConstantGain(Mmean, Mdev, D(s,t), R(s, t(1)), ...
        Ymean(s), Ydev(s,:), Knum(:,s), Ycov(s,s), calculateMean, calculateDevs);
    
    % Save output
    out.calibRatio(:,t) = calibRatio;
    if returnMean
        out.Amean(:,1,t) = permute(Amean, [1 3 2]);
    end
    if returnDevs
        out.Adev(:,:,t) = Adev;
    end
    
    % Do any calculations that require the deviations
    for c = 1:nCalcs
        calcs = Q.calculate;
    end
end

end  