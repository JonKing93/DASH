---
layout: simple_layout
title: Essentials
---

# Essential Inputs

There are four inputs that you must always provide in order to implement a Kalman Filter. These are
* Proxy records / Observations,
* Proxy / Observation Uncertainties,
* The Prior Ensemble, and
* Model estimates of proxies

You can provide these inputs using the "observations", "prior", and "estimates" commands.

### Proxy observations

You can specify proxy observations and their uncertainties using the "observations" command. Here, the syntax is:
```matlab
kf = kf.observations(Y, R)
```
Y is a matrix of observations; each row corresponds to a particular proxy site, and each column is a time step. R is the proxy uncertainty, and its form determines how proxy uncertainties are applied in the Kalman Filter. The following table specifies the possible forms of R

Type | Size | Application
---- | ---- | -----------
Scalar | 1 x 1 | Used as the uncertainty for all observations
Column Vector | Number of Proxy Sites x 1 | Each value is used as the uncertainty for the corresponding proxy in all time steps
Row Vector | 1 x Number of Time Steps | Each value is used as the uncertainty for all proxy observations in the corresponding time step
Matrix | Number of Proxy Sites x Number of Time Steps | Specifies a unique uncertainty for each observation

The output "kf" is a Kalman Filter object updated with the observations and uncertainties.

For example, I might have some proxy observations and uncertainties saved in a data file. Then I could use:
```matlab
data = load('my-proxy-data.mat', 'Y', 'R');
kf = kf.observations(data.Y, data.R);
```
to use these observations and uncertainties for the analysis.

### Prior

You can specify the prior ensemble using the "prior" command. Here the syntax is:
```matlab
kf = kf.prior(X);
```

where X is a state vector ensemble. Each row is a state vector element, and each column is an ensemble member. For example, if I have a state vector ensemble saved in a .ens file, I could do:
```matlab
ens = ensemble('my-ensemble.ens');
X = ens.load;

kf = kalmanFilter;
kf = kf.prior(X);
```
to use this ensemble as the prior for my analysis.

If a state vector ensemble is too large to load in active memory, you can alternatively provide the ensemble object directly. For example:
```matlab
ens = ensemble('my-ensemble.ens');
kf = kf.prior(ens);
```
However, Kalman Filter analyses are generally fastest for pre-loaded ensembles, so it is recommended to load the ensemble into memory when possible.

You can also use the "prior" command to specify an evolving prior, which we will examine later in this tutorial.

### Proxy Estimates

You must also provide proxy estimates in order to run a Kalman Filter. Do this using the "estimates" command. Here the syntax is:
```matlab
kf = kf.estimates(Ye)
```
where Ye is matrix of proxy estimates. Each row holds the estimates for a specific proxy site, and each column has the values for one ensemble member. The proxy sites should be in the same order as for the observations (Y), and the ensemble members should use the same order as the prior (M).

For example, if I have some PSM objects stored in a cell vector (named "myPSMs"), I could do:
```matlab
ens = ensemble('my-ensemble.ens');
X = ens.load;

Ye = PSM.estimate(X, myPSMs);

kf = kf.estimates(Ye);
```
to estimate proxy values and use them in a Kalman Filter Analysis.

### Run the filter

Once you have provided these essential inputs, you can run the Kalman Filter using the "run" command:
```matlab
output = kf.run;
```

Here, "output" is a structure that holds output quantities for the analysis. We will examine these quantities in detail later in the tutorial.

### Summary
Putting it all together, the setup for a Kalman Filter analysis will often resemble the following:
```matlab
% Load the proxy data, PSMs, and ensemble
proxies = load('my-proxy-data.mat', 'Y', 'R');
psms = load('my-psm-cell-vector.mat', 'myPSMs');
ens = ensemble('my-ensemble.ens');
X = ens.load;

% Estimate the proxy values
Ye = PSM.estimate(X, psms.myPSMs);

% Build and run the Kalman Filter
kf = kalmanFilter;
kf = kf.observations(proxies.Y, proxies.R);
kf = kf.prior(X);
kf = kf.estimates(Ye);
output = kf.run;
```

[Previous](object)---[Next](output)
