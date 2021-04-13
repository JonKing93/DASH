# Query covariance estimate
You can query the covariance estimate that will be used in an assimilated time step using the "covarianceEstimate" command. Here, the syntax is:
```matlab
[C, Ycov] = kf.covarianceEstimate(t);
```
where t is a scalar integer indicating one of the assimilated time steps. The output "C" is the covariance of the state vector elements with the observation sites and has size (State vector x Sites), and output "Ycov" is the covariance of the observation sites with one another and has size (Sites x Sites). This method returns the covariance estimate after applying any inflation, localization, and blending. It will also return the user-specified covariance estimate if one was provided.

For example, I could use:
```matlab
t = 5;
[C, Ycov] = kf.covarianceEstimate(t);
```
to obtain the covariance estimate used by the Kalman Filter if the fifth assimilated time step.
