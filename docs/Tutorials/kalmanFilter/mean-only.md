# Only update the ensemble mean
In some cases, you may be interested in only updating the ensemble mean. This can significantly speed up calculations, so can be useful in exploratory analyses where the spread of the posterior ensemble is not required.

To only update the mean, you should disable any outputs that require updating the ensemble deviations. Outputs that require ensemble deviations are:
1. [Posterior variance](variance) (Avar)
2. [Percentiles](percentiles) (Aperc)
3. [Deviations](deviations) (Adev), and
4. [Posterior indices](indices) (index_&lt;name&gt;)

By default, only the posterior variance is enabled. You can disable it by calling the [variance command](variance) with false as the input. For example:
```matlab
kf = kalmanFilter;
kf = kf.variance(false)
```
creates a Kalman Filter that will only update the ensemble mean.
