---
layout: simple_layout
title: Variable Metadata
---

# Variable Metadata
You can use the "variable" method to retrieve metadata for the dimensions of a particular variable in a state vector ensemble.
```matlab
metaStruct = ensMeta.variable( varName )
```
Here varName is the name of a particular variable in the state vector. metaStruct is a structure whose fields are the dimensions for the variable. For state dimensions, the contents of the field will be a metadata matrix with one row per state vector element for the variable. For ensemble dimensions, the contents of the field will be a metadata matrix with one row per ensemble member.

For example, say I have a state vector ensemble with variables "T", "Tmean", and "P" and 100 ensemble members. Let's say the state vector for "P" has 3000 elements. The ensemble dimensions are "time" and "run", and the state dimensions are "lat" and "lon". Then for:
```matlab
metaStruct = ensMeta.variable("P")
```
metaStruct will contain fields "lat", "lon", "time", and "run". The contents of the "lat" and "lon" fields will be matrices with 3000 rows. The contents of the "time" and "run" fields will be matrices with 100 rows.

### State Dimension Means
If you take a mean over a state dimension, then the metadata for the mean will be propagated along the third dimension. Consider the "Tmean" variable from the previous example. Let's say I took a mean over its "lat" and "lon" dimensions, which have 50 and 100 elements respectively. The "Tmean" variable has a single state vector element (that of the global mean). If I do:
```matlab
metaStruct = ensMeta.variable("Tmean");
```
then the contents of the "lat" field in metaStruct will be a (1 x nLatCols x 50) array. One row for the single state vector element, however many columns are used in its metadata format, and 50 elements used in the mean. Similarly, the contents of the "lon" field would be a (1 x nLonCols x 100) array.

### Specify dimensions
You can specify which dimensions to retrieve metadata for using the second input.
```matlab
metaStruct = ensMeta.variable(varName, dims)
```
Here, dims is a string vector listing the dimensions of interest. Using my previous example:
```matlab
metaStruct = ensMeta.variable("P", ["lat","time"])
```
metaStruct will only contain two fields: "lat" and "time".

If you only provide a single dimension, then the "variable" command will return the metadata directly.
```matlab
meta = ensMeta.variable(varName, dim);
```

Using the previous example:
```matlab
lat = ensMeta.variable("P", "lat");
```
would return a matrix with 3000 rows directly. Similarly,
```matlab
time = ensMeta.variable("P", "time");
```
would return a matrix with 100 rows directly.

### Specify metadata direction

You can use the third input to specify whether to return metadata from down the state vector or across the ensemble for any particular dimension, via:
```matlab
metaStruct = ensMeta.variable(varName, dims, direction)
```
 This is most commonly used for an ensemble dimension with a sequence. In this case, the dimension has (sequence) metadata down the state vector, but the "variable" command returns the metadata across the ensemble by default.

To specify metadata down the state vector, direction may be any of: "state", "s", "down", "d", "rows", "r", or true. To specify metadata across the ensemble, direction may be any of: "ensemble", "ens", "e", "across", "a", columns", "c", or false. If direction is a string scalar or logical scalar, then the same direction will be used for all dimensions. If you want to specify different directions for different dimensions, you can use a string vector or logical vector with one element per listed dimension.

Using my previous example, let's say that the "time" dimension uses a 3 element sequence with sequence metadata:
```matlab
seqMeta = ["May"; "June"; "July"];
```
In this case,
```matlab
meta = ensMeta.variable("P", "time", "state");
```
will return a string vector with 3000 elements. Each element will either be "May", "June", or "July".

If you request metadata across the ensemble for a state dimension, the "variable" command will return an empty array. If you request metadata down the state vector for an ensemble dimension without a sequence, the method will return a NaN vector with one element per state vector element for the variable.

### Metadata at specific indices

You can use the fourth input to specify specific indices at which to return metadata for a dimension.
```matlab
meta = ensMeta.variable(varName, dim, direction, indices);
```
Here, indices may either be:
1. A vector of linear indices, or
2. A logical vector with either one element per state vector element, or one element per ensemble members, as appropriate.

For example,
```matlab
lat = ensMeta.variable("P", "lat", "state", [1 6 100 7]);
```
would return a matrix with 4 rows. The first row would be the latitude metadata for the first element of the "P" variable down the state vector, the second element for the sixth element of "P" down the state vector, and next the 100th and then 7th elements down the state vector.

To specify indices for multiple dimensions, group the indices in a cell.
```matlab
metaStruct = ensMeta.variable(varName, dims, direction, indexCell);
```
The order of indices must match the order in which dimensions are listed in dims. Note that you can use an empty array to return all metadata for a dimension. For example:
```matlab
indexCell = {[1 3 8], [3 4 5 6], []};
metaStruct = ensMeta.variable("P", ["lat","lon","time"], [], indexCell);
```
will return latitude metadata for the first, third, and eighth elements down the state vector; longitude metadata for the third through sixth elements down the state vector; and all time metadata across the ensemble.

[Previous](sizes)---[Next](dimension)
