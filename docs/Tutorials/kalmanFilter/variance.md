# Select or disable the ensemble variance output

You can use "kalmanFilter.variance" to select whether the ensemble mean is returned as output. Here the syntax is:
```matlab
kf = kf.variance( returnVariance );
```
where "returnVariance" is a scalar logical indicating whether to return the variance. By default, a Kalman Filter analysis returns the variance. You can do:
```matlab
returnVariance = false;
kf = kf.variance( returnVariance );
```
to disable this output.

### Output field
If you return the posterior ensemble variance, then the output of a Kalman Filter analysis will include a field named "Avar". This will hold the posterior ensemble mean in each time step and will have size (State vector x Time).
