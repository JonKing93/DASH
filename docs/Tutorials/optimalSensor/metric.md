# Reconstruction target metric
To run an optimal sensor experiment, you must specify a method for computing the target reconstruction metric (J) from the prior. This allows the algorithm to construct a probability distribution for the metric from the prior ensemble.

You can specify a metric using the "optimalSensor.metric" command. Here the syntax is:
```matlab
os = os.metric( type, parameter1, parameter2, .., parameterN)
```
where "type" is a string that indicates the scheme used to calculate the metric, and parameters 1 through N are any additional parameters needed to calculate the metric.

Currently, optimalSensor only supports a metrics computed from a weighted average of elements in the prior. However, other metric schemes are in the works.

### Mean
You can calculate a reconstruction metric as a mean of state vector elements using the "mean" metric type. Here, the most basic syntax is:
```matlab
os = os.metric('mean');
```

This will compute the reconstruction metric as the mean of all elements in the prior. For example, if my state vector consists of summer temperature grid points in the western US, the target reconstruction metric will be mean summer temperature in the western US.

##### Weighted mean
You can also apply a weighted mean using the second input:
```matlab
os = os.metric('mean', weights)
```
where "weights" is a vector the length of the state vectors in the prior. Each element indicates the weight to use for the corresponding state vector element.

For example, if I have a state vector consisting of a global grid of annual temperatures, and I want to use mean global temperatures as the target reconstruction metric. I should use a latitude-weighted mean to calculate mean global temperatures, and I could do:
```matlab
lats; % A vector with the latitude of each state vector element

weights = cosd(lats);
os = os.metric('mean', weights);
```
to implement this.

##### Limit mean to specific state vector rows
You can also limit the calculation of the mean to specific state vector rows using the third input:
```matlab
os = os.metric('mean', [], rows);
```
where rows is either:
1. A logical vector the length of the state vector that indicates which rows to use in the mean, or
2. A set of linear indices for the state vector

For example, if I have ensemble metadata for a state vector variable with multiple variables, and I want to use the mean of the "Temperature" variable as the reconstruction target metric. Then I could do:
```matlab
ensMeta; % Ensemble metadata for the prior

variable = 'Temperature;'
rows = ensMeta.findRows( variable );

os = os.metric('mean', [], rows);
```

If using a weighted mean with the "rows" input:
```matlab
os = os.metric('mean', weights, rows);
```
then the "weights" input should have one element per row indicated in "rows".
