# Return default covariance estimate
You can use the "dash.estimateCovariance" command to return the default/initial covariance estimate between a prior and observation estimates. This is the covariance estimate used by a Kalman Filter ***before*** applying inflation, localization, or blending. Here, the syntax is:
```matlab
[C, Ycov] = dash.estimateCovariance(X, Ye);
```
where X is a state vector ensemble, and Ye is a set of observation estimates. The output "C" is the covariance of the state vector with the observation sites, and "Ycov" is the covariance of the observation sites with one another.
