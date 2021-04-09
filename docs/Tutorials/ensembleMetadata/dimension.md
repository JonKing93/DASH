
# Metadata for a dimension over all variables

You can use the "dimension" command to obtain all the metadata for a particular dimension down a state vector over all variables. This is often useful when implementing covariance localization. To get the metadata for a dimension down the entire state vector, provide the name of the dimension as the first input:
```matlab
meta = ensMeta.dimension( dim )
```

If the state vector has multiple variables, and the variables use the same format for the dimension's metadata, then the metadata is returned directly as an array with one row per element in the state vector. For example, say I have a state vector that has a "T" variable with 1000 elements, a "Tmean" variable with 1 element, and a "P" variable with 1000 elements. All use the same metadata format for the "lat" dimension. Then in the line:
```matlab
meta = ensMeta.dimension("lat")
```
"meta" will be an array with 2001 rows.

If the state vector has multiple variables, but the variables use a different format for the dimension's metadata, then the metadata is returned as a structure. The structure will have one field for each variable in the state vector and the contents of each field will be the dimension's metadata down the state vector for that variable. For example, if the "T", "Tmean", and "P" variables do not use the same metadata format for the "lat" dimension, then in the line:
```matlab
meta = ensMeta.dimension("lat")
```
"meta" will be a structure with a "T", "Tmean", and "P" field. The contents of the "T" field will be an array with 1000 rows, the "Tmean" field will hold an array with 1 row, and the "P" field will hold an array with 1000 rows.

If a variable does not have the specified dimension, then its metadata will be an array of NaN values (for numeric arrays), NaT values (for datetime metadata), or empty strings (for character/string/cellstring metadata). The metadata for the variable will still have one row per state vector element.

### Always return a structure

When writing scripts, it can be useful to always return outputs that use the same format. Consequently, you may want the "dimension" command to always return a structure, even if the variables use a common format for the dimension's metadata. You can use the second input to indicate that metadata should always be a structure using the syntax:
```matlab
meta = ensMeta.dimension(dim, alwaysStruct)
```
Here, alwaysStruct is a logical that indicates whether output should always be a structure. Set it to true to return a structure even when variables use the same format for the dimension's metadata. For example:
```matlab
meta = ensMeta.dimension("lat", true)
```
will always return the metadata for the latitude dimension as a structure.
