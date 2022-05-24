function[sse] = sse(obj)
%% particleFilter.sse  Compute the sum of squared errors for particles
% ----------
%   sse = obj.sse
%   Computes the sum of squared errors for each ensemble member in each
%   time step. The sum of squared errors evaluate the similarity of each
%   ensemble member to the observations. Lower SSE values indicate 
%   greater similarity between an ensemble members and the observations.
%   SSE values are computed as the sum of uncertainty-weighted innovations
%   for each ensemble member in each time step. This method requires the 
%   particle filter object to have observations, estimates, and
%   uncertainties. Does not require a prior.
%
%   The SSE values are the basic input to the different weighting schemes
%   for a particle filter, so you can use them to implement new weighting
%   schemes. Another application of SSE values is to rank the members of an
%   ensemble by their similarity to the observations.
% ----------
%   Outputs:
%       sse (numeric matrix [nMembers x nTime]): The SSE values for a
%           particle filter. Each row holds the weights for a particular
%           ensemble member. Each column holds weights for an assimilation
%           time step. Lower values indicate greater similarity to the proxy
%           observations.
%
% <a href="matlab:dash.doc('particleFilter.sse')">Documentation Page</a>

% Setup
header = "DASH:particleFilter:sse";
dash.assert.scalarObj(obj, header);

% Require observations, estimates, uncertainties (but not prior)
if ~obj.isfinalized
    obj = obj.finalize(false, 'computing particle SSEs', header);
end

% Preallocate sum of squared errors
sse = NaN(obj.nMembers, obj.nTime);

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
        sse(:,t) = reshape(sseP, obj.nMembers, numel(t));
    end

% If using R covariance, find the unique R covariances. This will include
% both different covariance matrices, and different sets of sites.
else
    sites = ~isnan(obj.Y)';
    Rcovs = [sites, obj.whichR];
    [Rcovs, ~, whichR] = unique(Rcovs, 'rows');
    nCovs = size(Rcovs, 1);

    % Get time steps and sites associated with each covariance
    for c = 1:nCovs
        times = find(whichR == c);
        t1 = times(1);
        s = sites(t1, :);

        % Invert the covariance matrix
        Rcov = obj.Rcovariance(t1, s);
        Rinv = Rcov ^ -1;

        % For each time step, get the innovations at all the sites
        for k = 1:numel(times)
            t = times(k);
            p = obj.whichPrior(t);
            innovation = obj.Y(s,t) - obj.Ye(s,:,p);

            % Get the SSE for each ensemble member
            for m = 1:obj.nMembers
                sse(m,t) = innovation(:,m)' * Rinv * innovation(:,m);
            end
        end
    end
end

end