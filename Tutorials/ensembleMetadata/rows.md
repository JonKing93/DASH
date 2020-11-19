---
layout: simple_layout
title: Row metadata
---

# Metadata at specific rows

Sometimes, you may want to obtain the metadata for a particular row of a state vector. This can be used to further [sort output from closestLatLon](closest#multiple-closest-rows), and as a sanity check to ensure that methods like "closestLatLon" and "find-rows" have been used correctly in conjunction. To query the metadata at specific rows, use the "rows" method using the syntax:
```matlab
meta = ensMeta.rows( rows );
```
Here, "rows" is either a vector of linear indices, or a logical vector with one element per state vector row. The output "meta" will hold the metadata at the specified rows. The form of "meta" will differ depending on whether you specify rows from a single state vector variable or across multiple state vector variables. If the rows are from a single variable, then "meta" will be a structure. The first field of "meta" is named "stateVectorVariable" and lists the name of the variable covered by the rows. The remaining fields are the dimensions of the variable. The contents of each field are the metadata for the dimension at the specified rows. For example, say I have a state vector that includes a "T" variable with 1000 state vector elements, a "Tmean" variable with 1 element, and a "P" variable with 1000 elements. Each of the variables has a "lat", "lon", and "time" dimension. Let's say I query the metadata at rows 1 through 5 using the line:
```matlab
rows = 1:5;
meta = ensMeta.rows(rows);
```
All 5 queried rows are from the "T" variable, so the output "meta" will be a structure with a "stateVectorVariable" field that holds the string "T", a "lat" field with latitude metadata at rows 1 through 5, a "lon" field with longitude metadata at the 5 rows, and a "time" field with time metadata at the 5 rows.

If the queried rows span multiple variables, then "meta" will be a structure whose fields are the names of the variables spanned by the rows. The field for each variable is also a structure. Each variable's substructure will have a field named "rows" that indicates which of the queried rows are in the variable. Each substructure will also have a field for each dimension of the variable. Continuing the previous example, let's say I query rows 1 through 5 and 1002 through 1012 using the line:
```matlab
rows = [1:5, 1002:1012];
meta = ensMeta.rows(rows);
```
The first five queried rows are from the "T" variable, while the last 11 rows are from the "P" variable. In this case "meta" will be a structure with two fields named "T" and "P", each of which holds a structure. The "T" structure has a field named "rows" with contents
```matlab
meta.T.rows = [1; 2; 3; 4; 5];
```
It also has a "lat", "lon", and "time" field
```matlab
meta.T.lat
meta.T.lon
meta.T.time
```
which hold the latitude, longitude, and time metadata at state vector rows 1 through 5. The "P" structure has a field named "rows" with contents:
```matlab
meta.P.rows = 1002:1012
```
It also has a "lat", "lon", and "time" field:
```matlab
meta.T.lat
meta.T.lon
meta.T.time
```
which hold the latitude, longitude, and time metadata at state vector rows 1002 through 1012.

### Query row metadata for specific dimensions
You can query row metadata for specific dimensions using the second input:
```matlab
meta = ensMeta.rows(rows, dims)
```
where dims is a string vector that lists dimensions. If you only list a single dimension, and the rows span a single variable, then the method returns metadata directly as an array. For example, if I do:
```matlab
rows = 1002:1012;
latMeta = ensMeta.rows(rows, 'lat')
```
then latMeta will be an array of latitude metadata with 11 rows.

If you specify multiple dimensions, then "meta" will be one of the structure outputs, but will only hold metadata for the specified dimensions. For example, if I do:
```matlab
rows = 1002:1012;
dims = ["lat", "lon"]
meta = ensMeta.rows(rows, dims);
```
then the output "meta" will have a "lat" and a "lon" field, but will not have a "time" field.

If a variable does not have one of the listed dimensions, then "meta" will only indicate the queried rows covered by the variable. For example, let's say that the "T" and "P" variables do not use the "coord" dimension, but I use the line:
```matlab
rows = [1:5 1002:1012];
meta = ensMeta.rows(rows, 'coord')
```
then the output "meta" will have a "T" and a "P" field as before. The "T" structure will still have a "rows" field indicating rows 1 through 5, but it will not have a "coord" field because the "T" variable does not have a "coord" dimension. Likewise, the "P" field will have a "rows" field indicating rows 1002 through 1012 and no other fields.

### Return variable names
You can return variable names at queried rows by setting the second input to 0:
```matlab
meta = ensMeta.rows(rows, 0);
```

For example, the line:
```matlab
rows = [1 2 3 1001 1002 1003];
meta = ensMeta.rows(rows, 0);
```
will produce the following "meta" output
```matlab
meta = ["T"; "T"; "T"; "Tmean"; "P"; "P"];
```

### Always use the same output format
When writing scripts, it can be useful to always return outputs that use the same format. You can use the third input to indicate that "rows" output should always use the same format:
```matlab
meta = ensMeta.rows(rows, dims, fullStruct)
```
Here, fullStruct is a logical that indicates that output should always use the nested structure format. This is the format where the fields of the "meta" output are the variables covered by the rows, and where each variable's substructure includes a "rows" field. Set it to true to ensure that the "meta" output always uses this format. For example, the line:
```matlab
rows = 1:5;
meta = ensMeta.rows(rows, 'lat', true);
```
will return "meta" as a structure with a "T" field rather than as an array of latitude metadata.

<br>
Alright, that's the tutorial. You can find more examples of how to use ensembleMetadata objects in the PSM and kalmanFilter tutorials. If you are interested in concatenating ensembles, removing ensemble members or variables, or exercising greater control over metadata queries, check out the [ensembleMetadata advanced topics](advanced).

[Previous](closest)---[All Tutorials](../welcome)
