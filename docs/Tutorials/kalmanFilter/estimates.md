---
sections:
  - Observation estimates
  - Typical workflow
  - Transient priors
  - Time-dependent estimates
---
# Observation Estimates
You must provide observation estimates (Ye) to run a Kalman Filter analysis. The estimates allow comparison of each ensemble member with the observations in order to update the ensemble.

You can provide estimates using the "kalmanFilter.estimates" command. Here, the syntax is:
```matlab
kf = kf.estimates(Ye);
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
kf = kf.estimates(Ye);
```
to provide them to a Kalman Filter.

### Typical workflow
It is common to use the [PSM.estimate](../PSM/estimate) command to estimate proxy observations. Say I have a cell vector of [PSM obejcts](../PSM/object), then I could do:
```matlab
F; % A cell vector of PSM objects

ens = ensemble('my-ensemble.ens');
X = ens.load;
Ye = PSM.estimate(X, F);

kf = kalmanFilter;
kf = kf.estimates(Ye);
```

### Transient priors
If you are using transient priors in a Kalman Filter analysis, you should organize estimates for the different priors along the third dimension of Ye. For example, if I have two sets of Y estimates
```matlab
Ye1 = [11 12 13 14 15
       101 102 103 104 105];

Ye2 = [21 22 23 24 25
       121 122 123 124 125];

Ye = cat(3, Ye1, Ye2);
kf = kf.estimates(Ye);
```

Note that the [PSM.estimate](../PSM/estimate) command will do this automatically if given multiple priors. For example:
```matlab
F; % A cell vector of PSM objects

ens1 = ensemble('my-ensemble-1.ens');
ens2 = ensemble('my-ensemble-2.ens');
X = cat(3, ens1.load, ens2.load);

Ye = PSM.estimate(X, F);
kf = kf.estimates(Ye);
```

### Time-dependent estimates

If you specify Ye for multiple priors, then you can use the second input to specify which prior to use in each time step. The syntax is:
```matlab
kf = kf.prior(Ye, whichPrior);
```
where whichPrior is a vector with one element per assimilated time step. Each element of whichPrior indicates which prior (element along dimension 3) to update in the corresponding time step. Note that you do not need to provide this argument if you already specified a "whichPrior" input using the [kalmanFilter.prior](prior) command.
