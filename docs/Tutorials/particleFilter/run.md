
# Run a Kalman Filter

Before running a Kalman Filter, you must provide all essential inputs. To recap, these are:
1. Y: Proxy records / observations ()[observations command](observations))
2. R: Observations uncertainties ([uncertainties command](uncertainties))
3. Ye: Observation estimates ([estimates command](estimates))

Note that you do not need to provide a prior in order to run a particle filter.

Once you have provided the essential inputs, you can run a particle filter analysis using the "kalmanFilter.run" command. Here, the syntax is:
```matlab
output = kf.run;
```

At its most basic, output is a structure with a single field:

Name | Size | Description
---- | ---- | -----------
weights | Ensemble members X Time | The weight for each particle in each time step. The weights in each time step sum to 1.

However, the particle filter class also includes options for returning an updated prior. You can read more about this option, and also how to select different weighting schemes on the [Advanced Topics](advanced) page.
