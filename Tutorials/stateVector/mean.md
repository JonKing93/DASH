---
layout: simple_layout
title: Mean
---

# Take a mean over a dimension

It is often useful to take the mean of a dimension in a state vector variable. For example, you could take the mean over the "lon" dimension so that state vector elements are zonal means. Or you could take the mean over the "time" dimension if you want state vector elements to average over multiple months or years. To take a mean, we will use "mean" method.

<br>
### Take a mean over state dimensions

To take a mean over state dimensions of variables, provide in order
1. The names of the appropriate variables, and
2. The names of the state dimensions over which to take a mean.

For example, if "lat" and "lon" are state dimensions, then:
```matlab
vars = ["T","P"];
dims = ["lat","lon"];
sv = sv.mean(vars, dims);
```
will take a mean over the "lat" and "lon" dimensions of the "T" and "P" variables.

<br>
### Take a mean over ensemble dimensions

To take a mean over an ensemble dimension, you will also need to provide [mean indices](dimension-indices#mean-indices) as the third input. For example:
```matlab
sv = sv.mean('T', 'time', [0 1 2])
```

To take a mean over multiple ensemble dimensions, the third input should be a cell vector with one element per listed dimension. Each element should hold the mean indices for the associated dimension. For example
```matlab
dims = ["time", "run"];
meanIndices = {[0 1 2], 0:11};
sv = sv.mean('T', dims, meanIndices);
```
would take a 3 element mean over the time dimension, and a 12 element mean over the run dimension.

<br>
### Take a mean over a mix of state and ensemble dimensions

To specify mean options for both state and ensemble dimensions simultaneously, use the same syntax as for multiple ensemble dimensions and use empty arrays as the mean indices for the state dimensions. For example, say that "lat" and "lon" are state dimensions and "time" is an ensemble dimension. Then:
```matlab
dims = ["lat","lon","time"];
indices = {[], [], [0 1 2]};
sv = sv.mean('T', dims, indices);
```
would take a mean over all three dimensions.

<br>
### Optional: Specify NaN options

You can use the fourth input to specify how to treat NaN values in a mean. By default, NaN values are included in means. To omit NaN values from the means of all listed dimensions, use either of the following options:
```matlab
sv = sv.mean(variables, dimensions, indices, 'omitnan')
sv = sv.mean(variables, dimensions, indices, true)
```

To include NaN values for all listed dimensions, use either of the following options:
```matlab
sv = sv.mean(variables, dimensions, indices, 'includenan')
sv = sv.mean(variables, dimensions, indices, false)
```

If you would like to specify different NaN options for different dimensions, use either a string vector or logical vector with one element per listed dimension. For example:
```matlab
dims = ["lat","lon","time"];

% Different settings with a string vector
nanflag = ["includenan", "omitnan", "includenan"];
sv = sv.mean(variables, dims, indices, nanflag);

% Different settings with a logical vector.
omitnan = [false, true, false];
sv = sv.mean(variables, dims, indices, omitnan);
```
would include NaN values in means taken over the "lat" and "time" dimensions, but omit NaN values in the mean taken over the "lon" dimension.

<br>
### Optional: Reset Mean options

You can reset mean options for variables and dimensions. When you reset the options, no mean is taken. Use
```matlab
sv.resetMeans
```
to reset means for all dimensions of all variables in a state vector.

Use:
```matlab
sv.resetMeans(variableNames)
```
to reset means for all dimensions of specific variables, and
```matlab
sv.resetMeans(variableNames, dimensionNames)
```
to reset means for specific dimensions of listed variables.

[Previous](sequence)   [Next](weighted-mean)
