---
sections:
  - Covariance inflation
  - Time-dependent inflation
---
# Covariance Inflation

Covariance inflation multiplies proxy covariances by a scalar greater than 1. This increases covariance estimates, effectively increasing the proxy weights in the filter. Use the "kalmanFilter.inflate" command to implement covariance inflation. Here the syntax is:
```matlab
kf = kf.inflate( factor );
```
where factor is the inflation factor, a scalar greater than 1. For example:
```matlab
kf = kf.inflate(2)
```
would multiply covariance estimates by 2.

### Time-dependent inflation
In some cases, you may wish to use different inflation factors in different time steps. Do so using the second input:
```matlab
kf = kf.inflate( factors, whichFactor )
```
Here, "factors" is a vector of inflation factors. The "whichFactor" input is a vector with one element per assimilated time step. Each element of "whichFactor" indicates the element of "factors" to use as the inflation factor in the corresponding time step.

For example, say I have seven time steps. I want to use an inflation factor of 2 for the first 3 time steps, and an inflation factor of 6 for the last four time steps. Then I could do:
```matlab
factors = [2, 6];
whichFactor = [1 1 1 2 2 2 2];
kf = kf.inflate(factors, whichFactor);
```
