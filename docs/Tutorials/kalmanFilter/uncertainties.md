---
sections:
  - Observation uncertainty
  - Error variances
  - Time-dependent variances | | 2
  - Error covariances
  - Time-dependent covariances | | 2
  - NaN values
---
# Observation Uncertainty

You must provide observation uncertainties (R) in order to run a Kalman Filter analysis. These uncertainties are used to weight the observations in the Kalman Filter.

You can provide observation uncertainties using the "kalmanFilter.uncertainties" command. Here the general syntax is:
```matlab
kf = kf.uncertainties(R)
```
where R is a set of observation uncertainties. There are two options you can use for observations uncertainties; you may either provide:
1. A set of error variances, or
2. Error covariance matrices

### Error variances

If your observations have uncorrelated measurement errors, you can provide R uncertainties as a set of error-variances. In this case, R is a matrix with one row per observation site. If R has a single column, then the same uncorrelated error-variance is used for each site in each time step. For example, if I have 3 observations sites, I could do:
```matlab
R = [4
     15
     1];

kf = kf.uncertainties(R);
```
to use an error variance of 4 for the first site, 15 for the second site, and 1 for the third in each time step.

##### Time-dependent variances

If R has multiple columns, then different error-variances can be used in different time steps. If R has one column per assimilated time step, each column of R values will be used for the corresponding time step. If R has a different number of columns, you must use the second input to specify which set of error variances to use in each time step. Here, the syntax is:
```matlab
kf = kf.uncertainties(R, whichR);
```
where "whichR" is a vector with one element per time step. Each element of whichR indicates which column of R values to use for the corresponding time step.

For example, say I have observations in 7 time steps. I have one set of R values that I want to use for the first 3 time steps, and a second set of R values for the last 4 time steps:
```matlab
R1 = [4; 15; 1];   % For time steps 1-3
R2 = [3; 17; 3];   % For time steps 4-7

R = [R1, R2];
```

Then I could do:
```matlab
nTime = 7;
whichR = NaN(1, nTime);

whichR(1:3) = 1;  % First set of R values in time steps 1-3
whichR(4:7) = 2;  % Second set of R values for 4-7

kf = kf.uncertainties(R, whichR);
```
to implement this.

### Error covariances

If your observations have correlated errors, then you should instead provide a set of error-covariances. In this case, use the syntax:
```matlab
kf = kf.uncertainties(Rcov, [], true);
```
Here, Rcov is a covariance matrix for the errors of the observation sites. Note that you must set the third input to "true" to indicate that you are providing an error-covariance matrix.

For example, if I have 3 observation sites with the following covariance matrix, the following covariance matrix:
```matlab
Rcov = [6 2 1
        2 7 4
        1 4 3];
```
Then I should use:
```matlab
kf = kf.uncertainties(Rcov, [], true);
```

##### Time-dependent covariances

You can provide multiple error covariance matrices by organizing them down the third dimension. If Rcov has a single element along the third dimension, then the same R covariances will be used in each time step. If the third dimension of Rcov has one element per time step, then each successive covariance matrix will be used for the corresponding time step.

However, if you have a different number of elements along the third dimension, you should use the second input to specify which set of R covariances to use in each time step. Here, the syntax is:
```matlab
kf = kf.uncertainties(Rcov, whichR, true);
```
where whichR is a vector with one element per time step. Each element of whichR indicates which covariance matrix (element along dimension 3) to use for the corresponding time step. For example, say I two covariance matrices organized along the third dimension:
```matlab
R1 = [6 2 1
      2 7 4
      1 4 3];

R2 = [4 3 1
      3 5 2
      1 2 6];

Rcov = cat(3, R1, R2);
```

Let's also say I have seven time steps; I want to use the first covariance matrix in the first 3 time steps, and the second covariance matrix for the last 4 time steps. Then I could do:
```matlab
nTime = 7;
whichR = NaN(1, nTime);

whichR(1:3) = 1;  % First covariance matrix in the first 3 time steps
whichR(4:7) = 2;  % Second covariance matrix in the last 4 time steps

kf = kf.uncertainties(Rcov, whichR, true);
```

### NaN Values
R values can include NaNs, but only for time steps where the corresponding proxy does not have observations.
