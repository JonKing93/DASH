function[out] = run(pf)
%% Runs a particleFilter object

% Check for essential inputs. Set defaults
pf = pf.finalize('run a particle filter');
update = ~isempty(pf.M);

% Preallocate
out = struct();
out.weights = NaN(pf.nSite, pf.nTime);
if update
    out.A = NaN(pf.nState, pf.nTime);
end
if pf.Rcov
    sse = NaN(pf.nEns, pf.nTime);
end

% Permute for singleton expansion
Y = permute(pf.Y, [1 3 2]);

% Process each prior, get the associated estimates and time steps
for p = 1:pf.nPrior
    Ye = pf.Ye(:,:,p);
    t = pf.whichPrior==p;
    
    % Vectorize sum of squared errors for R variance
    innov = Y(:,:,t) - Ye;
    if ~pf.Rcov
        R = permute(pf.R(:,t), [1 3 2]);
        sse = nansum( (1./R).*(innov).^2, 1);
        sse = squeeze(sse);
        
    % Compute sum of squared errors in each time step for R covariance
    else
        for k = 1:numel(t)
            time = t(k);
            Rinv = pf.R(:,:,time)^-1;
            for m = 1:pf.nEns
                sse(m, time) = innov(:,m,k)' * Rinv * innov(:,m,k);
            end
        end
    end
    
    % Compute particle filter weights
    w = pf.weights(sse);
    out.weights(:,t) = w;
    
    % Update the prior
    if update
        out.A(:,t) = pf.M(:,:,p) * w;
    end
end

end