
# Additional Covariance options

Although covariance localization and blending are among the most common covariance adjustments in paleoclimate applications, DASH supports additional methods, including covariance inflation and directly specifying a covariance matrix. This page details these methods as well as several other useful commands for covariance workflows.

### Covariance inflation

Covariance inflation multiplies covariance estimates by a scalar value. This can help proxy observations maintain influence in a Kalman Filter even when an ensemble becomes highly underdispersive. You can implement covariance inflation using the "inflate" command. Here the syntax is:
```matlab
kf = kf.inflate(factor);
```
where factor is a scalar value greater than 1 that specifies the multiplicative inflation factor. For example
```matlab
kf = kf.inflate(2);
```
will cause covariance estimates from the prior to be multiplied by 2. Note that inflation is applied to covariance estimates from the prior *before* localization and blending.

Alternatively, you can use different inflation factors in different time steps using the second input:
```matlab
kf = kf.inflate(factors, whichFactor);
```
Here, factors is a vector of different inflation factors. The input "whichFactor" indicates which inflation factor to use in each assimilated time step. It is a vector with one element per time step, and each element is the index of one of the values in "factors".

### Set covariance directly

In some cases, you may wish to specify the covariance estimates directly for a Kalman Filter. You can do this using the "setCovariance" command. Here the syntax is:
```matlab
kf = kf.setCovariance(C, Ycov);
```
Here, C and Ycov are the same as the inputs for [blending](blend). C specifies the covariance of state vector elements with proxies, and Ycov is the covariance of proxies with one another.

You can also set different covariances in different time steps using the third input:
```matlab
kf = kf.setCovariance(C, Ycov, whichCov);
```
Here, as in the [blending syntax](blend#blend-different-covariances-in-different-time-steps), C and Ycov have different covariance estimates organized down the third dimension, and whichCov is a vector with one element per assimilated time step. Each element of whichCov holds the index of the covariance estimate along the third dimension of C and Ycov that should be used for a particular time step.

### Reset Covariance Options

You can remove all specified covariance adjustments from a Kalman Filter using the "resetCovariance" command.
```matlab
kf = kf.resetCovariance;
```
After calling this command, the kalmanFilter object will use the covariance estimate from the prior. It will not inflate, localize, or blend the covariance, and it will not use a user-specified covariance estimate.

### Get covariance of an assimilated time step

In some cases, you may want to obtain the covariance estimate used in a particular assimilated time step. This can be useful if, say, you want to plot covariance maps for the different proxies in an assimilation. You can use the "covarianceEstimate" command to obtain these estimates:
```matlab
[C, Ycov] = kf.covarianceEstimate(t)
```
Here, t is a scalar integer that specifies the index of a particular time step. For example, if I wanted to obtain the covariance estimate used in the 17th assimilated time step, I could do:
```matlab
[C, Ycov] = kf.covarianceEstimate(17);
```
Here, C has dimensions (State vector x Proxies), and Ycov is a symmetric matrix with dimensions (Proxies x Proxies). Note that these covariance estimates will include any inflation, localization, blending, or user-specified covariance used in the assimilation.

 If you are interested in mapping proxy covariances, recall that [ensembleMetadata.regrid](..\ensembleMetadata\regrid) can be used to shape state vectors back into gridded spatial fields. For example, if I have a temperature variable named "T", I could do:
```matlab
[C, Ycov] = kf.covarianceEstimate(17);
[C_gridded, meta] = ensMeta.regrid(C, 'T');
```
to get the gridded covariance map (and associated metadata) for all of the proxies.

### Estimate Covariance

As touched on in the [covariance blending section](blend), you can use the command "dash.estimateCovariance" to estimate covariance for a ensemble and associated proxy estimates. Here the syntax is:
```matlab
[C, Ycov] = dash.estimateCovariance(X, Ye);
```
where X is the usual ensemble, Ye are the associated proxy estimates, and C and Ycov are the covariance estimates.
