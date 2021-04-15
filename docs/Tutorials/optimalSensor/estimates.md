# Observation Estimates
You must specify observation estimates (Ye) in order to run an optimal sensor experiment. These are estimates of the observations for each ensemble member at the tested sampling sites. The covariance of these estimates with the target metric is used to help rank the sampling sites.

There are two ways to provide observation estimates for an optimal sensor:

1. Provide the estimates directly. The estimates will be updated via the Kalman Gain as optimal sampling sites are selected. This option is best for estimates computed as a linear function of state vector elements.

2. Provide proxy system models (PSMs) to calculate estimates dynamically. The PSMs are re-run on the updated prior as optimal sampling sites are selected. This option is best when using highly non-linear PSMs.

Here, we will focus on providing estimates directly. However, see the [page on PSM inputs](psms) to provide PSMs instead.

### Provide estimate directly

To provide estimates directly, use the "optimalSensor.estimates" command. Here, the syntax is:
```matlab
os = os.estimates(Ye, R);
```
where Ye is a matrix of observation estimates for the potential sampling sites. Each row of Ye should hold the estimates for a particular site, and each column is the estimates for a specific ensemble member. Ye cannot include NaN values.

The input "R" is the error-variance for each set of estimates. R should be a vector of positive values with one element per potential sampling site and cannot contain NaN values.

### Provide PSMs
To provide PSMs, use the "optimalSensor.psms" command. Here, the syntax is:
```matlab
os = os.psms(F, R);
```
where F is a cell vector of [PSM objects](../PSM/object) with one element per potential sampling site. Once again, R is a vector of error-variances for the sampling sties. The optimalSensor class currently does not support dynamic R estimation from PSMs, so R may not contain NaN values.
