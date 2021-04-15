# Observation Estimates
You must provide observation estimates (Ye) to run a particle filter analysis. The estimates allow comparison of each ensemble member with the observations in order to weight the particles.

You can provide estimates using the "particleFilter.estimates" command. Here, the syntax is:
```matlab
pf = pf.estimates(Ye);
```
where Ye is a matrix of observation estimates. Each row of Ye should hold the estimates for a particular site, and each column holds estimates for a particular ensemble member. Ye cannot include NaN values.

For example, say I have a prior with five ensemble members, and two observation sites. I have estimates:
```matlab
Ye1 = [11 12 13 14 15];
Ye2 = [101 102 103 104 105];

Ye = [Ye1; Ye2];
```
Then I could do:
```matlab
pf = pf.estimates(Ye);
```
to provide them to a particle filter.

### Typical worpflow
It is common to use the [PSM.estimate](../PSM/estimate) command to estimate proxy observations. Say I have a cell vector of [PSM obejcts](../PSM/object), then I could do:
```matlab
F; % A cell vector of PSM objects

ens = ensemble('my-ensemble.ens');
X = ens.load;
Ye = PSM.estimate(X, F);

pf = particleFilter;
pf = pf.estimates(Ye);
```

### Transient priors
If you are using transient priors in a particle filter analysis, you should organize estimates for the different priors along the third dimension of Ye. For example, if I have two sets of Y estimates
```matlab
Ye1 = [11 12 13 14 15
       101 102 103 104 105];

Ye2 = [21 22 23 24 25
       121 122 123 124 125];

Ye = cat(3, Ye1, Ye2);
pf = pf.estimates(Ye);
```

Note that the [PSM.estimate](../PSM/estimate) command will do this automatically if given multiple priors. For example:
```matlab
F; % A cell vector of PSM objects

ens1 = ensemble('my-ensemble-1.ens');
ens2 = ensemble('my-ensemble-2.ens');
X = cat(3, ens1.load, ens2.load);

Ye = PSM.estimate(X, F);
pf = pf.estimates(Ye);
```

### Estimates for different time steps

If you specify Ye for multiple priors, then you can use the second input to specify which prior to use in each time step. The syntax is:
```matlab
pf = pf.prior(Ye, whichPrior);
```
where whichPrior is a vector with one element per assimilated time step. Each element of whichPrior indicates which set of estimates (element along dimension 3) to use in the corresponding time step. For example, say I have two priors and seven time steps. If I want to use the estimates from the first prior to update the first 3 time steps, and the estimates from the second prior to update the last 4 time steps, I could do:
```matlab
Ye1; % Estimates for the first prior
Ye2; % Estimates for the second prior
Y = cat(3, Ye1, Ye2);

nTime = 7;
whichPrior = NaN(1, 7);

whichPrior(1:3) = 1;   % First prior for the first 3 time steps
whichPrior(4:7) = 2;   % Second prior for the last 4 time steps

pf = pf.estimates(Ye, whichPrior);
```

Note that you do not need to provide this argument if you already specified a "whichPrior" input using the [particleFilter.prior](prior) command.
