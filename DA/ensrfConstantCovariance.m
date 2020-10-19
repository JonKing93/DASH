function[Amean, Adev, calibRatio] = ensrfConstantCovariance( M, Y, D, R, whichprior, Knum, Ycov)
%% Updates an evolving offline ensemble in time steps that use the same
% covariance estimates

% Sizes
[nSite, nTime] = size(D);
[nState, nEns, nPrior] = size(M);

% Preallocate
calibRatio = NaN(nSite, nTime);
if returnMean
    Amean = NaN(nState, 1, nTime);
else
    Amean = [];
end
if returnDevs
    Adev = NaN(nState, nEns, nTime);
else
    Adev = [];
end

% Cycle through each prior, get the associated timesteps
for p = 1:nPrior
    time = find(whichprior==p);
    
    % Decompose ensembles
    [Mmean, Mdev] = decompose( M(:,:,p) );
    [Ymean, Ydev] = decompose( Y(:,:,p) );
    
    % Get the sets of unique Kalman Gains (requires the same covariance
    % estimates, observation sites, and R)
    sites = ~isnan(D(:,time));
    gains = [sites; R(:,times)]';
    [~, iA, iC] = unique(gains, 'rows');
    
    % Get the time steps associated with each gain
    for k = 1:numel(iA)
        t = time(iC==k);
        t1 = t(1);
        s = sites(:, t1);
        
        % Update
        [Am, Ad, cr] = ensrfConstantGain(Mmean, Mdev, D(s,t), R(s,t1), ...
            Ymean(s), Ydev(s,:), Knum(:,s), Ycov(s,s), calculateMean, calculateDevs);
        
        % Save output
        calibRatio(:,t) = cr;
        if returnMean
            Amean(:,1,t) = permute(Am, [1 3 2]);
        end
        if returnDevs
            Adev(:,:,t) = Ad;
        end
    end
end

end  