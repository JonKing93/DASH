---
layout: simple_layout
title: Weighted Means
---

# Weighted Means

Often, it is useful to take a weighted mean over dimensions of a variable. For example, you may wish to take a latitude weighted mean when averaging over data from a climate model grid. Or you may wish to take a time mean that gives different weights to different months.

To take a weighted mean, use the "weightedMean" method and provide in order
1. The names of the variables with a weighted mean,
2. The names of the dimensions with a weighted mean,
3. The weights

Weights should be a numeric vector. If weights are for a state dimension, they should have one element per [state index](dimension-indices#state-and-reference-indices). If weights are for an ensemble dimension, they should have one element per [mean index](dimension-indices#mean-indices). For example
```matlab
sv = sv.design('T', 'lat', 'state', 49:96)
weights = cosd( lat(49:96) );
sv = sv.weightedMean('T', 'lat', weights)
```
could be used to provide weights for a mean over state dimension "lat". Likewise
```matlab
sv = sv.design('T', 'time', 'ensemble', 1:12:12000)
sv = sv.mean('T', 'time', 0:5)
weights = [1 2 3 3 2 1];
sv = sv.weightedMean('T', 'time', weights);
```
could be used to provide weights for a mean over ensemble dimension "time".

<br>
### Provide weights for multiple dimensions using a cell

If you want to provide weights for multiple dimensions, one option is to use a cell vector with one element per listed dimension. Each element should contain the weights for the corresponding dimension. For example:
```matlab
dims = ["lat", "time"];
weights = {latWeights, timeWeights};
sv = sv.weightedMean(variables, dims, weights)
```
could be used to specify mean weights for the "lat" and "time" dimensions.

<br>
### Provide weights for multiple dimensions using an array.

Sometimes, you may have a multi-dimensional array of weights. For example, some climate models provide "areacella" output, a matrix that reports the area of each grid cell. Such output can be used to take area weighted means as an alternative to latitudinal weights. To use an array of weights, the dimensions of the weights must be in the same order as listed dimensions. For example, say that "lat" and "lon" are state dimensions 96 and 144 state indices, respectively. Then, to make the following call:
```matlab
sv = sv.weightedMean(variables, ["lat", "lon"], weights)
```
weights should be a 96 x 144 matrix. By contrast, to do
```matlab
sv = sv.weightedMean(variables, ["lon", "lat", weights])
```
weights should be a 144 x 96 matrix.

<br>
### Resetting means

Whenever you use the ["resetMeans" method](mean#optional-reset-mean-options), all weights are deleted for the specified dimensions.

[Previous](mean)   [Next](build-ensemble)
