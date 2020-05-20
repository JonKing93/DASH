function[output] = ensrf( M, D, R, Y, w, yloc, returnMean, returnVar, percentiles, returnDevs, showProgress )
% Runs the ensemble square root kalman filter
%
% output = ensrf( M, D, R, Y, w, yloc, returnMean, returnVar, percentiles,
%                 returnDevs, showProgress )
%
% ----- Inputs -----
%
% M: Prior model ensemble (nState x nEns)
%
% D: Observations (nObs x nTime)
%
% R: Observation uncertainty (nObs x nTime)
%
% Y: Observation estimates (nObs x nEns)
%
% w: Observation-ensemble covariance localization weights (nState x nObs)
%
% yloc: Observation estimate covariance localization weights (nObs x nObs)
%
% returnMean: Whether to return the updated ensemble mean as output. Scalar
%             logical.
%
% returnVar: Whether to return the variance of the updated ensemble as
%            output. A scalar logical.
%
% percentiles: The ensemble percentiles to return. A vector of values
%              between 0 and 100.
%
% returnDevs: Whether to return the updated ensemble deviations as output.
%             A scalar logical.
%
% ----- Output -----
%
% output: A structure that may contain the following fields
%
%   calibRatio: Calibration ratios for the observations (nObs x nTime)
%
%   Amean: The updated ensemble mean (nState x nTime)
%
%   Avar: The variance of the updated ensemble (nState x nTime)
%
%   Aperc: The percentiles of the updated ensemble (nState x nPercentile x nTime)
%
%   Adev: The updated ensemble deviations (nState x nEns x nTime)

% Preallocate output. Determine whether to calculate mean and deviations.
[nObs, nTime] = size(D);
[nState, nEns] = size(M);
[output, calculateMean, calculateDevs] = obj.preallocateENSRF( nObs, nTime, ...
    nState, nEns, returnMean, returnVar, percentiles, returnDevs );

% Decompose ensembles
[Mmean, Mdev] = dash.decompose(M);
[Ymean, Ydev] = dash.decompose(Y);

% Get the static Kalman numerator
Knum = obj.kalmanNumerator( Mdev, Ydev, w );

% Get the unique sets of obs + R for the various time steps (each set has
% a unique Kalman Gain)
hasobs = ~isnan(D);
obsR = [hasobs;R]';
[~, iA, iC] = unique( obsR, 'rows' );
nSet = numel(iA);

% Progress bar
if showProgress
    progressbar(0);
end

% Get the time steps, obs, and R for each set
for k = 1:nSet
    t = (iC==k);
    nt = numel(t);   % Numer of time steps in the set
    obs = hasobs(:, t(1));
    Rset = R(obs, t(1));
    
    % Get the Kalman Gain
    Kdenom = obj.kalmanDenominator( Ydev(obs,:), Rset, yloc(obs,obs) );
    K = Knum(:,obs) / Kdenom;
    
    % Update the mean
    if calculateMean
        Amean = obj.updateMean( Mmean, K, D(obs,t), Ymean(obs) );
    end
    
    % Calibration ratio
    output.calibRatio(obs,t) = (D(obs,t)-Ymean(obs)).^2 ./ diag(Kdenom);
    
    % Update the deviations
    if calculateDevs
        Ka = obj.kalmanAdjusted( Knum(:,obs), Kdenom, Rset );
        Adev = obj.updateDeviations( Mdev, Ka, Ydev );
    end
    
    % Save mean
    if returnMean
        output.Amean(:,t) = Amean;
    end
    
    % Save deviations
    if returnDevs
        output.Adev(:,:,t) = repmat( Adev, [1,1,nt]);
    end
    
    % Ensemble variance
    if returnVar
        Avar = sum(Adev.^2, 2) ./ (nEns-1);
        output.Avar(:,t) = repmat( Avar, [1,nt] );
    end
    
    % Ensemble percentiles
    if returnPercs
        Amean = permute(Amean, [1 3 2]);
        Aperc = prctile( Adev, percentiles, 2 );
        output.Aperc(:,:,t) = Amean + Aperc;
    end
    
    % Progress bar
    if showProgress
        progressbar(k/nSet);
    end
end

end