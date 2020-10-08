---
layout: simple_layout
title: State Vector Metadata
---

# State Vector Metadata
Once you have an ensembleMetadata object, you can use the "dimension" command to return the metadata down the state vector for a particular dimension.
```matlab
ensMeta.dimension("lat")
```

# Metadata Format
If the different variables in the state vector use the same metadata format (data type and number of columns) for the specified dimension, then the "dimension" command will return a matrix with one row per state vector element as output. If the variables use different metadata formats, then the "dimension" command will return a structure. The fields of the structure will be the names of the variables, and the contents of each field will be a matrix with one row per state vector element associated with that variable.

For example, say I have a state vector with two variables: "Temp" and "Precip". The "Temp" variable is first and has 3000 elements in the state vector. The "Precip" variable is second and has 1000 elements. If both variables have metadata for the "lat" dimension that is numeric and has a single column, then for:
```matlab
latMeta = ensMeta.dimension("lat")
```
latMeta will be a numeric matrix with 4000 rows and 1 column. The first 3000 elements of latMeta will be for the "Temp" variable, and the last 1000 elements will be for the "Precip" variable.

For a contrasting example: say that both variables have numeric metadata for the "lat" dimension. However, the lat metadata for "Temp" has one column, but the metadata for "Precip" has two columns. Then for:
```matlab
latMeta = ensMeta.dimension("lat");
```
latMeta will be a structure with two fields: "Temp" and "Precip". The contents of
```matlab
latMeta.Temp
```
will be a numeric matrix with 3000 rows and 1 column. The contents of
```matlab
latMeta.Precip
```
will be a numeric matrix with 1000 rows and 2 columns. Similar behavior will occur if the variables use different data types (for example, if lat metadata is numeric for "Temp", but a string for "Precip").

### Variables without metadata

If a variable does not have metadata for the specified dimension, the "dimension" command will return a placeholder value for each of the variable's state vector elements. When returning a matrix as output, the fill value for each of the variable's elements will be NaN for numeric metadata, NaT for datetime metadata, and an empty string for string/char/cellstring metadata. When returning a structure as output, the fill value will be NaN for each element.

### Optional: Always return a structure

For complex codes, you may want to ensure that the "dimension" command always returns the same type of output. You can use the second input to specify whether output should always be a structure.
```matlab
ensMeta.dimension(dimName, alwaysStruct)
```
Here alwaysStruct is a scalar logical. Set its value to true to only always return output as a structure. For example:
```matlab
ensMeta.dimension("lat", true)
```
will always return lat metadata as a structure, and never as a matrix.

[Previous](meta-object)---[Next](coordinates)
