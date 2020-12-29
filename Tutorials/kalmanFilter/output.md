---
layout: simple_layout
title: Output
---

# Kalman Filter Output

The "run" command returns a structure that holds output quantities from a Kalman Filter analysis:
```matlab
output = kf.run;
```

You can use the kalmanFilter object to specify what quantities are calculated and returned in this structure.

### Default output

By default, the output structure contains three fields
1. Amean: This field holds the updated (posterior) ensemble mean for the analysis. It will be a matrix with dimensions (State vector elements x Updated time steps)

2. Avar: This field holds the variance of the updated ensemble at each state vector element. It is also a matrix with dimensions (State vector elements x Updated time steps).

3. calibRatio: This field holds the calibration ratio for each proxy observation in each updated time step. It is a matrix with dimensions (Proxy sites x Updated time steps).

### Disable variance

DASH uses an ensemble square root Kalman Filter, which updates the ensemble mean separately from the ensemble deviations. Updating deviations is typically the most computationally expensive task in a Kalman Filter analysis, so DASH only updates the deviations when they are necessary to calculate output quantities.

If you have an analysis that only requires the updated ensemble mean, you can significantly speed up calculations by disabling the ensemble variance output (which requires the updated deviations). You can do this using the "variance" command and setting the input to false
```matlab
kf = kf.variance(false);
```
which will remove the "Avar" field from the output structure.

Note that this will only speed up processing if you do not enable other output fields that require ensemble deviations (such as ensemble [percentiles](#posterior-percentiles), [deviations](#posterior-deviations), or ![deviations for a mean INSERT LINK()),

### Posterior percentiles

You can have the analysis calculate percentiles across the updated ensemble using the "percentiles" command. Here the syntax is:
```matlab
kf = kf.percentiles( percs );
```
where percs is a vector of percentiles between 0 and 100. When you use this command, DASH will return the requested percentiles of the updated ensemble in the output structure. These percentiles will be saved in a field named "Aperc" which will have dimensions (State vector elements x Percentiles x Updated Time Steps).

For example, if I do
```matlab
percs = [1 99 5 95 50];
kf = kf.percentiles(percs);

output = kf.run;
```
Then the output structure will contain a field named "Aperc" that holds a 3 dimensional array. The first column of Aperc will hold the 1st percentile of the updated ensemble, the second column will hold the 99th percentiles of the updated ensemble, etc.

If you previously specified percentiles, but no longer want to compute them, you can disable them by calling the "percentiles" command with an empty array. For example:
```matlab
kf = kf.percentiles([]);
```
will disable percentiles for an analysis.


### Posterior deviations

You can also return the full set of posterior deviations directly in the output, using the "deviations" command and setting the input to true:
```matlab
kf = kf.deviations(true)
output = kf.run;
```
This will cause the output structure to include a field "Adev", which will hold the updated ensemble deviations. Adev will have dimensions (State vector elements x Ensemble members x Updated time steps).

It is worth noting that the posterior deviations are often very large and can quickly exceed the memory available to a computer. Consequently, trying to return the full set of deviations can result in Out-of-Memory errors for many analyses.

### Disable the ensemble mean

You can remove the ensemble mean from the output by using the "mean" command and setting the input to false.
```matlab
kf = kf.mean(false);
```

[Previous](essential)---[Next](index)
