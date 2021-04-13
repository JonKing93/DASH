# Set covariance directly

In some cases, you may wish to specify the covariance estimates directly for a Kalman Filter. This can be useful if covariance is known, or if you want to provide covariances for state vector rows with NaN values in the prior. You can specify covariance using the "setCovariance" command. Here the syntax is:
```matlab
kf = kf.setCovariance(C, Ycov);
```
where "C" holds the covariance estimates between the state vector elements and the proxy sites and has dimensions (State vector x Observation Sites x Priors). Similarly, "Ycov" holds the covariance estimates of the proxies with one another; it has dimensions (Sites x Sites x Priors).

### Covariance for different time steps

In some cases, you may wish to use different covariance estimates in different time steps. To do so, organize different covariance estimates down the third dimension of C and Ycov. Then, indicate which covariance to use in each time step using the third input:
```matlab
kf = kf.setCovariance(C, Ycov, whichCov);
```
Here, "whichCov" is a vector with one element per assimilated time step. Each element of "whichCov" indicates the covariance estimate (element along the third dimension) to use in the corresponding time step.
