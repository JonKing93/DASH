function[weights] = computeWeights(obj)
%% particleFilter.computeWeights  Return the weights for a particle filter
% ----------
%   weights = obj.computeWeights
%   Computes particle filter weights for an assimilation. Requires the
%   particle filter object to have observations, estimates, uncertainties, 
%   and a prior.
% ----------
%   Outputs:
%       weights (numeric matrix [nMembers x nTime]): The weights for a
%           particle filter. Each row holds the weights for a particular
%           ensemble member. Each column holds weights for an assimilated
%           time step.
%
% <a href="matlab:dash.doc('particleFilter.computeWeights')">Documentation Page</a>

% Setup
header = "DASH:particleFilter:computeWeights";
dash.assert.scalarObj(obj, header);

% Require finalized filter
if ~obj.isfinalized
    obj = obj.finalize;
end

% Preallocate sum of squared errors
sse = NaN(1, obj.nMembers, obj.nTime);

% If using R variances, permute observations for singleton expansion of 
% Y over members and Ye over time
if obj.Rtype == 0
    Y = permute(obj.Y, [1 3 2]);

    % Get the innovation for each prior
    for p = 1:obj.nPrior
        t = find(obj.whichPrior==p);
        innovation = Y(:,:,t) - obj.Ye(:,:,p);

        % Permute R for singleton expansion over members
        R = obj.R(:, obj.whichR(t));
        R = permute(R, [1 3 2]);

        % Vectorize sum of squared errors for the prior
        sseP = (1./R) .* innovation.^2;
        sseP = sum(sseP, 1, 'omitnan');
        sse(:,t) = reshape(sseP, nMembers, nTime);
    end

% If using R covariance, find the unique R covariances. This will include
% both different covariance matrices, and different sets of sites.
else
    sites = ~isnan(pf.T)';
    Rcovs = [sites, obj.whichR];
    [Rcovs, ~, whichR] = unique(Rcovs, 'rows');
    nCovs = size(Rcovs, 1);

    % Get time steps and sites associated with each covariance
    for c = 1:nCovs
        times = find(whichR == c);
        t1 = times(1);
        s = sites(t1, :);

        % Invert the covariance matrix
        Rinv = obj.R(t1, s)^-1;

        % For each time step, get the innovations at all the sites
        for k = 1:numel(times)
            t = times(k);
            p = pf.whichPrior(t);
            innovation = obj.Y(s,t) - obj.Ye(s,:,p);

            % Get the SSE for each ensemble member
            for m = 1:obj.nMembers
                sse(m,t) = innovation(:,m)' * Rinv * innovation(:,m);
            end
        end
    end
end

% Calculate weights using the appropriate weighting scheme
if obj.weightType == 0
    method = 'bayesWeights';
elseif obj.weightType == 1
    method = 'bestNWeights';
end
weights = particleFilter.(method)(sse, obj.weightArgs{:});

end