
# Variable Metadata

The "variable" command is one of the most versatile methods for working with ensemble metadata. As the name suggests, this command returns the metadata for a variable in the state vector. In the most basic use of the command, provide the name of a variable as the only input:
```matlab
meta = ensMeta.variable( varName )
```

In this case, "meta" is a structure whose fields are the different dimensions of the variable. By default, the "variable" method will return metadata down the state vector for [state dimensions](..\stateVector\concepts#state-and-ensemble-dimensions), and metadata across the ensemble for [ensemble dimensions](..\stateVector\concepts#state-and-ensemble-dimensions).

For example, consider a state vector ensemble that has 75 ensemble members, and a "T" variable with 1000 state vector elements. Let's say that "time" and "run" are ensemble dimensions, and that the spatial "lat" and "lon" dimensions are state dimensions. In this case:
```matlab
meta = ensMeta.variable("T")
```
meta will be a structure with a "lat", "lon", "time", and "run" field. The contents of the "lat" and "lon" fields will each have 1000 rows, each corresponding to a state vector element for the variable. The "time" and "run" fields will each have 75 rows, each corresponding to an ensemble member.

### Return metadata for specific dimensions

You can use the second input to specify which dimensions should have their metadata returned.
```matlab
meta = ensMeta.variable(varName, dims)
```

If you list a single dimension, then the method will return the metadata directly as an array, rather than as a structure. Continuing the example, in the following line:
```matlab
timeMeta = ensMeta.variable("T", 'time')
```
timeMeta will be an array with 75 rows. Similarly, in the line:
```matlab
latMeta = ensMeta.variable('T', 'lat')
```
latMeta will be an array with 1000 rows. (If this complicates your code, you can use the [fifth input](#always-return-a-structure) to always return a structure).

If you list multiple dimensions, then the method will return a metadata structure. For example:
```matlab
dims = ["time", "lat", "lon"];
meta = ensMeta.variable("T", dims)
```
in this case, "meta" will be a structure with a "time", "lat", and "lon" field.

# Down the state vector vs. across the ensemble

By default, the "variable" method will return metadata down the state vector for [state dimensions](..\stateVector\concepts#state-and-ensemble-dimensions) and across the ensemble for [ensemble dimensions](..\stateVector\concepts#state-and-ensemble-dimensions). However, you can use the third input to select the metadata direction for each variable. This is most commonly used when an ensemble dimension has a sequence and you want the metadata for the sequence down the state vector. Continuing the example, say the "time" dimension for the "T" variable is an ensemble dimension, but also has a sequence of four months (May, June, July, and August) down the state vector. If I have a proxy system model that requires May temperatures, then I will need the monthly "time" metadata down the state vector to find data from May.

To specify metadata direction, use the following syntax:
```matlab
meta = ensMeta.variable(varName, dims, direction);
```
where "direction" is a string or logical that indicates whether to return metadata down the state vector or across the ensemble.

To return metadata down the state vector, you can use any of the following options:
```matlab
meta = ensMeta.variable(varName, dims, 'state')
meta = ensMeta.variable(varName, dims, 's')
meta = ensMeta.variable(varName, dims, 'down')
meta = ensMeta.variable(varName, dims, 'd')
meta = ensMeta.variable(varName, dims, 'rows')
meta = ensMeta.variable(varName, dims, 'r')
meta = ensMeta.variable(varName, dims, true)
```

To return metadata across the ensemble, you can use any of the following options:
```matlab
meta = ensMeta.variable(varName, dims, 'ensemble')
meta = ensMeta.variable(varName, dims, 'ens')
meta = ensMeta.variable(varName, dims, 'e')
meta = ensMeta.variable(varName, dims, 'across')
meta = ensMeta.variable(varName, dims, 'a')
meta = ensMeta.variable(varName, dims, 'columns')
meta = ensMeta.variable(varName, dims, 'c')
meta = ensMeta.variable(varName, dims, false)
```

To specify different directions for different dimensions, you can use a string or logical vector with one element per listed dimension. For example:
```matlab
dims = ["time", "run", "lat", "lon"];

% Using a string vector
direction = ["state", "ensemble", "state", "state"];
meta = ensMeta.variable('T', dims, direction)

% Using a logical vector
direction = [true, false, true, true];
meta = ensMeta.variable('T', dims, direction);
```
would return metadata down the state vector for the "time", "lat", and "lon" dimensions, and metadata across the ensemble for the "run" dimension.

### Query specific rows or columns

You can use the fourth input to query the metadata at specific columns across the ensemble, or at specific rows for the variable down the state vector.
```matlab
meta = ensMeta.variable(varName, dim, direction, indices);
```
Here indices is a vector of linear indices for specific columns or rows in the variable. Alternatively, indices can be a logical vector with one element per ensemble member or state vector element, as appropriate.

For example, if I wanted to return time metadata for ensemble members 1, 5, and 17, I could do:
```matlab
meta = ensMeta.variable('T', 'time', 'ensemble', [1 5 17]);
```

Similarly, if I wanted to return latitude metadata for rows 8, 20, and 22, then I could do:
```matlab
meta = ensMeta.variable('T', 'lat', 'state', [8 20 22]);
```

It's important to note that rows are queried relative to a specific variable, and **not** relative to the full state vector. The previous line would query the metadata at rows 8, 20, and 22 of the "T" variable, which are not necessarily rows 8, 20, and 22 of the full state vector.

If you want to query multiple dimensions at once, the syntax becomes:
```matlab
meta = ensMeta.variable(varName, dims, direction, indexCell)
```
Here, indexCell is a cell vector with one element per listed dimension. Each cell element contains the queried indices for each listed dimension. Use an empty array to return metadata at all points along a dimension. For example:
```matlab
dims = ["time", "run", "lat"];
direction = ["state", "ensemble", "state"];
indices = {[8 20 22], [1 5 17], []};
```
would return "time" metadata at rows 8, 20 and 22; "run" metadata for ensemble members 1, 5, and 17; and "lat" metadata for all 1000 rows of the "T" variable.

### Always return a structure

When scripting, it can be useful to always return outputs in a common form. Consequently, you may want to require the "variable" command to output a structure even when returning metadata for a single dimension. You can do this using the fifth input:
```matlab
meta = ensMeta.variable(varName, dims, direction, indices, alwaysStruct)
```
Here, alwaysStruct is a logical indicating whether the output should always be a structure. Set it to true to prevent metadata for a single dimension from being returned directly as an array. For example, in the following line:
```matlab
meta = ensMeta.variable('T', 'time', 'ensemble', [], true)
```
"meta" will be a structure with a single field ("time"), rather than an array.

<br>
The "variable" and "findRows" methods are sufficient to find metadata at any point in a state vector ensemble. However, some metadata tasks recur much more frequently than others. In the next few sections, we will see how to use the ensembleMetadata class to facilitate the use of covariance localization and proxy system models.
