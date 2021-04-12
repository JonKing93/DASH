# Proxy Estimates without PSM.estimate

You may want to use your own forward models to estimate observations for data assimilation without needing to create a new PSM class. If this is the case, you can do so by organizing proxy estimates into an array (Ye).

Ye should have dimensions:
1. Number of observation sites, by
2. Number of ensemble members, by
3. Number of priors

The sites should be in the same order as for the observation matrix. The ensemble members should be in the same order as in the prior, and the priors should be in the same order as provided when using transient priors.

The following script can be used as a rough template for generating proxy estimates
```matlab
nSite; % The number of observation sites
nEns; % The number of ensemble members
rows; % A cell vector. Each element holds the state vector
      % rows needed to run the forward model for a site.

% Preallocate estimates for a stationary prior
Ye = NaN(nSite, nEns);

% Load the ensemble
ens = ensemble('my-ensemble.ens');
X = ens.load;

% Generate each set of estimates
for s = 1:nSite
  Xsite = X(rows{s}, :);
  Ye(s,:) = myForwardModel( Xsite );
end
```

If you want to generate estimates for a transient prior, you can follow this template:
```matlab
nSite; % The number of observation sites
nEns; % The number of ensemble members
nPrior; % The number of transient priors
rows; % A cell vector. Each element holds the state vector
      % rows needed to run the forward model for a site.

% Preallocate the observation estimates
Ye = NaN(nSite, nEns, nPrior);

% Load the ensembles
ens = ensemble('my-transient-ensemble.ens');
X = ens.load;  % Different priors are organized along
               % the third dimension of X

% Generate the estimates
for s = 1:nSite
  Xsite = X(rows{s},:,:);

  for p = 1:nPrior
    Xprior = Xsite(:,:,p);
    Ye(s,:,p) = myForwardModel( Xprior );
  end
end
```
