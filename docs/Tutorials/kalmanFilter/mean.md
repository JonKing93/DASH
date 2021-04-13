# Select or disable the ensemble mean output

You can use "kalmanFilter.mean" to select whether the ensemble mean is returned as output. Here the syntax is:
```matlab
kf = kf.mean( returnMean )
```
where "returnMean" is a scalar logical indicating whether to return the mean. By default, a Kalman Filter analysis returns the mean. You can do:
```matlab
returnMean = false;
kf = kf.mean( returnMean )
```
to disable this output.

### Output field
If you return the posterior ensemble mean, then the output of a Kalman Filter analysis will include a field named "Amean". This will hold the posterior ensemble mean in each time step and will have size (State vector x Time).
