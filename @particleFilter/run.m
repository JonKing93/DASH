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

% Permute for singleton expansion
D = permute(pf.D, [1 3 2]);
R = permute(pf.R, [1 3 2]);

% Process each prior, get the associated estimates and time steps
for p = 1:pf.nPrior
    Y = pf.Y(:,:,p);
    t = pf.whichPrior==p;

    % Get the sum of squared errors for each ensemble member. Use to
    % compute particle filter weights
    sse = nansum( (1./R).*(D - Y).^2, 1);
    sse = squeeze(sse);
    w = pf.weights(sse);
    out.weights(:,t) = w;
    
    % Update the prior
    if update
        out.A(:,t) = pf.M(:,:,p) * w;
    end
end

end