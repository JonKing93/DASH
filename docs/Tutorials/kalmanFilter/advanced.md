# Additional Features

This tutorial covers the essential steps to implementing a Kalman Filter analysis. However, DASH includes many other options for working with Kalman Filters. In particular, these include options for:
1. Modifying covariance estimates, and
2. Selecting output quantities

### Covariance options
By default, the Kalman Filter estimates covariance using the prior and observation estimates. However, these covariance estimates may contain biases, and you may wish to adjust the estimates. The kalmanFilter module includes several options for this, which include:
* [Localization](localize): Localizes proxy covariance to a specified radius,
* [Inflation](inflate): Inflates the covariance of all proxies by a scalar,
* [Blending](blend): Combines the covariance estimate linearly with a user-defined estimate
* [Directly setting covariance](setCovariance): Allows a user to explicitly define covariances

It is worth noting that, when using multiple covariance adjustments, they are applied in the following order:
1. Inflation,
2. Localization,
3. Blending

The module also includes several helper methods for working with covariance estimates. These include
* [covarianceEstimate](covarianceEstimate): Returns the covariance estimate for a queried time step after applying any covariance adjustments,
* [dash.estimateCovariance](dash-estimate-covariance): Returns the default covariance estimate for a prior and observation estimates, and
* [resetCovariance](resetCovariance): Resets all covariance adjustment options for a Kalman Filter

### Output quantities
By default, DASH returns the posterior ensemble mean, posterior ensemble variance, and calibration ratio when running a Kalman Filter analysis. However, there are many other output options, which include:

* [Only updating the ensemble mean](mean-only): Speeds up calculations for exploratory analyses
* [Ensemble Deviations](deviations)
* [Ensemble Percentiles](percentiles), and
* [Calculating posterior climate indices](index)

You can also adjust the output to disable the [ensemble mean](mean), and/or [ensemble variance](variance).

If you are using these output options, you may find the [Output Quick-Reference Guide](output-reference) useful.
