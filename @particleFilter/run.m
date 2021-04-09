function[out] = run(pf)
%% Runs a particleFilter object

% Check for essential inputs. Set defaults
pf = pf.finalize('run a particle filter');
update = ~isempty(pf.X);

% Preallocate
out = struct();
sse = NaN(pf.nEns, pf.nTime);
if update
    out.A = NaN(pf.nState, pf.nTime);
end

% If using R variances, get the innovation for each prior
if ~pf.Rcov
    pf.Y = permute(pf.Y, [1 3 2]);
    for p = 1:pf.nPrior
        t = find(pf.whichPrior==p);
        innov = pf.Y(:,:,t) - pf.Ye(:,:,p);
        
        % Vectorize the sum of squared errors
        R = pf.R(:,pf.whichR(t));
        R = permute(R, [1 3 2]);
        sse(:,t) = squeeze( sum( (1./R).*(innov).^2, 1, 'omitnan') );
    end
    
% For covariances, start by finding the unique R covariances
else
    sites = ~isnan(pf.Y)';
    Rcovs = [sites, pf.whichR];
    [Rcovs, ~, whichR] = unique(Rcovs, 'rows');
    
    % Invert each covariance
    nCovs = size(Rcovs, 1);
    for c = 1:nCovs
        times = find(whichR==c);
        s = sites(times(1),:);
        Rinv = pf.Rcovariance(times(1), s)^-1;
        
        % Get the innovations for each time step
        for k = 1:numel(times)
            t = times(k);
            p = pf.whichPrior(t);
            innov = pf.Y(s,t) - pf.Ye(s,:,p);
            
            % Get the SSE for each ensemble member
            for m = 1:pf.nEns
                sse(m,t) = innov(:,m)' * Rinv * innov(:,m);
            end
        end
    end
end
            
% Compute the particle filter weights
out.weights = pf.weights(sse);

% Optionally update the prior
if update
    for p = 1:pf.nPrior
        t = find(pf.whichPrior==p);
        out.A(:,t) = pf.X(:,:,p) * out.weights(:, t);
    end
end

end