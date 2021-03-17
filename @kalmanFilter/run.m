function[out] = run(kf, showprogress, complexError)
%% Runs a Kalman Filter using an ensemble square root implementation
%
% output = kf.run
% Runs the Kalman Filter
%
% output = kf.run(showprogress)
% Specify whether to display a progress bar for the Kalman Filter.
%
% output = kf.run(showprogress, complexError)
% Specify whether to throw an error if the adjusted Kalman Gain becomes
% complex-valued. Default is to throw an error. If disabling the error,
% updated ensemble deviations are set to NaN is all time steps with a
% complex-valued adjusted gain.
%
% ----- Inputs -----
%
% showprogress: A scalar logical indicating whether to display a progress
%    bar (true), or not (false). By default, no progress bar is shown.
%
% complexError: A scalar logical indicating whether to throw an error when
%    the adjusted Kalman Gain becomes complex valued (true -- Default), or
%    whether to update using NaN deviations (false).
%
% ----- Outputs -----
%
% output: A structure containing output calculations

% Defaults and error check
if ~exist('showprogress','var') || isempty(showprogress)
    showprogress = false;
end
dash.assertScalarType(showprogress, 'showprogress', 'logical', 'logical');

if ~exist('complexError','var') || isempty(complexError)
    complexError = true;
end
dash.assertScalarType(complexError, 'complexError', 'logical', 'logical');

% Check for essential inputs and finalize whichArgs
kf = kf.finalize;

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

% Decompose ensembles
[Xmean, Xdev] = dash.decompose(kf.X, 2);
[Ymean, Ydev] = dash.decompose(kf.Ye, 2);

% Get the covariance settings for each time step. Find the unique
% covariances and the time steps associated with each
covSettings = [kf.whichPrior, kf.whichFactor, kf.whichLoc, kf.whichCov];
if kf.setCov
    covSettings(:, 1:3) = 0;
end
[covSettings, ~, whichCov] = unique(covSettings, 'rows');
nCov = size(covSettings, 1);

% Get all unique Kalman Gains
sites = ~isnan(kf.Y);
if ~kf.Rcov
    kf.R(~sites) = 0;
    gains = [sites; kf.R; whichCov']';
else
    gains = [sites; kf.whichRcov'; whichCov']';
end
[gains, ~, whichGain] = unique(gains, 'rows');

% Initialize progress bar
nGains = size(gains, 1);
progress = progressbar(showprogress, 'Running Kalman Filter:', nGains, ceil(nGains/100));

% Make each covariance estimate. Get its associated time steps, priors, and gains
for c = 1:nCov
    times = find(whichCov==c);
    p = kf.whichPrior(times(1));
    covGains = find(gains(:,end)==c);
    [Knum, Ycov] = kf.estimateCovariance(times(1), Xdev(:,:,p), Ydev(:,:,p));
    
    % Get the sites, time steps, and priors associated with each gain
    for g = 1:numel(covGains)
        t = times(whichGain == covGains(g));
        s = sites(:, t(1));
        
        % Get the R covariance. Build from variances if necessary
        if kf.Rcov
            r = gains(g, end-1);
            Rk = kf.R(s, s, r);
        else
            Rk = diag( kf.R(s, t(1)) );
        end
        
        % Kalman Gain and adjusted Gain
        Kdenom = Ycov(s,s) + Rk;
        K = Knum(:,s) / Kdenom;
        if updateDevs
            Ksqrt = sqrtm(Kdenom);
            Ka = Knum(:,s) * (Ksqrt^(-1))' * (Ksqrt + sqrtm(Rk))^(-1);
            
            % Check the adjusted gain is not complex valued
            realKa = isreal(Ka);
            if ~realKa && complexError
                error('The adjusted gain in time step %.f is complex valued. This can occur if the R covariance matrix for the time step has negative eigenvalues.');
            end
        end
        
        % Cycle through each prior that has updates using this gain. Get
        % the time steps that will be updated for each prior.
        [priors, ~, updatePrior] = unique( kf.whichPrior(t) );
        for pk = 1:numel(priors)
            p = priors(pk);
            tu = t(updatePrior==pk);
            
            % Update the mean and calibration ratio
            Amean = repmat(Xmean(:,:,p), [1 numel(tu)]);
            if any(s)
                innovation = kf.Y(s,tu) - Ymean(s,:,p);
                Amean = Amean + K * innovation;
                out.calibRatio(s,tu) = innovation.^2 ./ diag(Kdenom);
            end
            
            % Deviations
            if updateDevs
                Adev = Xdev(:,:,p);
                if any(s) && realKa
                    Adev = Adev - Ka * Ydev(s,:,p);
                elseif any(s) && ~realKa
                    Adev(:) = NaN;
                end
            end
            
            % Calculated indices
            for q = 1:numel(kf.Q)
                name = kf.Q{q}.outputName;
                td = kf.Q{q}.timeDim;
                
                indices = repmat({':'}, [1 td]);
                indices(td) = {tu};
                out.(name)(indices{:}) = kf.Q{q}.calculate(Adev, Amean);
            end
            
            % Save the mean and/or deviations as requested
            if kf.return_mean
                out.Amean(:,tu) = Amean;
            end
            if kf.return_devs
                out.Adev(:, :, tu) = Adev;
            end
        end
        
        % Update the progress bar
        progress.update;
    end
end

end