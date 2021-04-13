---
sections:
  - Run a Kalman Filter
  - Disable progress bar
  - Complex-valued output
---

# Run a Kalman Filter

Before running a Kalman Filter, you must provide all essential inputs. To recap, these are:
1. Y: Proxy records / observations ()[observations command](observations))
2. R: Observations uncertainties ([uncertainties command](uncertainties))
3. X: A prior or transient priors ([prior command](prior)), and
4. Ye: Observation estimates ([estimates command](estimates))

Once you have done so, you are ready to run a Kalman Filter analysis. Do this using the "kalmanFilter.run" command. Here, the syntax is:
```matlab
output = kf.run;
```

By default, "output" is a structure with three fields:

Name | Size | Description
---- | ---- | -----------
Amean | State vector elements X Time steps | The mean of the posterior ensemble in each time step
Avar | State vector elements X Time steps | The variance across the posterior ensemble in each time step
calibRatio | Observation sites X Time steps | The calibration ratio for each site in each time step

However, the DASH also includes options for returning:
* Ensemble percentiles
* Ensemble deviations, and
* Climate indices
from a Kalman Filter analysis. You can read more about these output options on the [Advanced Topics](advanced) page.

### Disable progress bar
By default, the "run" command will display a progress bar for the analysis. You can disable this progress bar by setting the second input to false:
```matlab
showProgress = false;
output = kf.run(showProgress);
```

### Complex-valued output
If you use R covariance matrices for observations that are strongly linearly dependent, numerical precision errors may cause the posterior ensemble to become complex-valued in some time steps. These values are not meaningful, and the "run" command will throw an error if this occurs. However, you can disable this error by setting the second input to false.
```matlab
throwError = false;
output = kf.run([], throwError);
```
If you disable this error, the posterior ensemble will be set to NaN in all time steps with complex-valued output.
