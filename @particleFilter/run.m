function[out] = run(pf)
%% Runs a particleFilter object

% Check for essential inputs. Set defaults
pf = pf.finalize('run a particle filter');

% Preallocate
out = struct();
out.A = NaN(pf.nState, pf.nTime);
out.weights = NaN(pf.nSite, pf.nTime);

% Permute for singleton expansion
D = permute(pf.D, [1 3 2]);
R = permute(pf.R, [1 3 2]);

% Process each prior, get the associated estimates and time steps
for p = 1:pf.nPrior
    Y = pf.Y(:,:,p);
    t = pf.whichPrior==p;

    % Get the sum of squared errors for each ensemble member
    sse = nansum( (1./R).*(D - Y).^2, 1);
    sse = squeeze(sse);
    
    % Compute particle weights and update the prior
    w = pf.weights(sse);
    out.A(:,t) = pf.M(:,:,p) * w;
    out.weights(:,t) = w;
end

end