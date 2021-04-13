# Reset Covariance Options
In some cases, you may wish to reset covariance options to their defaults. You can use the "resetCovariance" command to do this:
```matlab
kf = kf.resetCovariance;
```

This will delete any inflation factors, remove localization, disable blending, and delete any user-specified covariance matrices. After calling the function, covariance estimates will be generated via the default method of calculating covariance between the prior ensemble and observation estimates.
