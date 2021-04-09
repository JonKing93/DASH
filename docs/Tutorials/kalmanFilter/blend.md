
<script async src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>

# Covariance Blending

Sampling errors can cause covariance biases in small ensembles. Such ensembles often occur when constructing priors from an evolving set of parallel climate model simulations because running a large number of simulations can be computationally infeasible. One method to mitigate these sampling errors is to blend the covariance of the small, evolving prior with the covariance of a larger, static ensemble. The basic workflow for blending is to:
1. Obtain covariance estimates from a static ensembles, and
2. Provide these estimates to the Kalman Filter.

### 1. Static Covariance Estimates

You can estimate covariance for an ensemble and associated proxy estimates using the "dash.estimateCovariace" command. Here the syntax is:
```matlab
[C, Ycov] = dash.estimateCovariance(X, Ye);
```
where X a state vector ensemble, and Ye is a set of proxy estimates. The output "C" holds the covariance estimates between the state vector elements and the proxy sites and has dimensions (State vector x Proxies x Priors). Similarly, "Ycov" holds the covariance estimates of the proxies with one another; it has dimensions (Proxies x Proxies x Priors).

Typical workflow might resemble:
```matlab
psms = load('my-psms.mat', 'myPSMs');
ens = ensemble('my-large-static-ensemble.ens');
X = ens.load;
Ye = PSM.estimate(X, psms.myPSMs);

[C, Ycov] = dash.estimateCovariance(X, Ye);
```

### 2. Provide covariances to the Kalman Filter

You can implement covariance blending for a Kalman Filter using the "blend" command. Here the basic syntax is:
```matlab
kf = kf.blend(C, Ycov);
output = kf.run;
```
Note that blending is applied *after* any localization is applied to the covariance estimate from the prior.

### Specify blending weights

The Kalman filter will blend the covariance of the prior and the static ensemble as a linear combination:

$$C_{final} = aC_{static} + bC_{prior}$$

By default, DASH sets the coefficients $$a$$ and $$b$$ equal to 1/2, so that the final covariance is an equal mix of the two blended covariances. However, you can use the third input to the "blend" to specify custom coefficients:
```matlab
kf = kf.blend(C, Ycov, coeffs);
```
Here, coeffs is numeric and has two columns: the first column specifies the coefficient $$a$$ and the second column specifies $$b$$. For example, let's say I want to blend covariances such that the final covariance is 70% of the static covariance, and 30% of the covariance from the prior. Then I could do:
```matlab
coeffs = [.7 .3];
kf = kf.blend(C, Ycov, coeffs);
```
It is generally recommended (although not required), that the blending coefficients sum to 1.

### Blend different covariances in different time steps

In some cases, you might want to blend the covariance estimate from the prior with different covariances in different time steps. You can do this using the fourth input to the "blend" command:
```matlab
kf = kf.blend(C, Ycov, coeffs, whichCov);
```
Here, C and Ycov should have multiple covariance estimates organized down the third dimension. C will have size (State vector x Proxies x Ensembles), and Ycov will have size (Proxies x Proxies x Ensembles). Each row of coeffs will hold blending coefficients for one of the estimates. The input "whichCov" specifies which covariance estimate to blend in each assimilated time step. It is a vector with one element per time step, and each element holds the index of one of the covariance estimates down the third dimension of C and Ycov.

For example, let's say I have proxy observations in 1150 time steps. I want to blend covariance with a static ensemble in the first 1000 time steps using 50% of each estimate. I also want to blend covariance with a *different* static ensemble in the last 150 time steps using blending weights of 0.7 and 0.3. Then I could do:
```matlab
% Get the two static ensembles and PSMs
ens1 = ensemble('static-ensemble-1.ens');
ens2 = ensemble('static-ensemble-2.ens');
psms = load('my-psms.mat', 'myPSMs');

% Estimate the covariances
X = cat(3, ens1.load, ens2.load);
Ye = PSM.estimate(X, psms.myPSMs);
[C, Ycov] = dash.estimateCovariance(X, Ye);

% Specify blending options
coeffs = [0.5 0.5; 0.7 0.3];
whichCov = [ones(1000,1); 2*ones(150,1)];

kf = kf.blend(C, Ycov, coeffs, whichCov);
```
Here, the third dimension of C and Ycov has a length of 2 (one element for each static ensemble). The input "whichCov" indicates that the first thousand time steps should blend the first static ensemble, and the next 150 time steps should blend the second ensemble.
