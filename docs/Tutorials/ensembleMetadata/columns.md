# Metadata at specific columns

Sometimes you may want to query the metadata at particular columns in the state vector. This can be useful to sort output from the [variable command](variable) and as a sanity check when designing evolving priors. To query the metadata at specific rows, use the "columns" method using the syntax:
```matlab
meta = ensMeta.columns( columns )
```
Here, "columns" is either a vector of linear indices, or a logical vector with one element per ensemble member. The output "meta" will hold the metadata at the specified columns. If the state vector has a single variable, then "meta" will be a structure whose fields are the dimensions of the variable. Each field will hold the dimension's metadata for the queried columns. Note that the ***rows*** of the output metadata correspond to the queried ensemble members / columns.

For example, say I have a state vector with a "T" variable. The "T" variable has a two state dimension: "lat", and "lon". The "T" variable also has one ensemble dimension: "time". Then querying metadata at the first five ensemble members using:
```matlab
columns = 1:5;
meta = ensMeta.columns(columns)
```
will return "meta" as a structure with a "lat", "lon", and "time" field. The "time" field:
```matlab
meta.time
```
will have five rows, each row corresponding to the time metadata for one of the queried ensemble members. Since the "lat" and "lon" dimensions are state dimensions, they have no metadata across the ensemble. Consequently, the "lat" and "lon" fields hold empty arrays:
```matlab
meta.lat = []
meta.lon = []
```

If the state vector has multiple variables, then meta will be a structure whose fields are the names of the variables in the state vector. Each variable's field holds a structure whose fields are the dimensions of the variable. Each field holds the metadata for the queried ensemble members.

Changing the example, say the state vector has a "T", "Tmean", and a "P" variable. All have "lat" and "lon" state dimensions and "time" as an ensemble dimension. The "P" variable also has "run" as an ensemble dimension. In this case, using:
```matlab
columns = 1:5;
meta = ensMeta.columns(columns)
```
returns output "meta" that has three fields: "T", "Tmean", and "P". Each of these fields holds a structure. The "T" and "Tmean" structures have fields "lat", "lon", and "time".
```matlab
meta.T.lat
meta.T.lon
meta.T.time
```
which hold the metadata for the "T" and "Tmean" variables at the 5 queried ensemble members. The "P" structure has fields "lat", "lon", "time", and "run":
```matlab
meta.P.lat
meta.P.lon
meta.P.time
meta.P.run
```
which hold the metadata for the P variable at the 5 queried ensemble members.

### Query specific variables
You can return metadata for specific variables using the second input:
```matlab
meta = ensMeta.columns(columns, varNames)
```
Here, "varNames" is a vector of strings listing variables in the state vector. For example, if I do
```matlab
columns = 1:5;
varNames = ["T", "Tmean"];
meta = ensMeta.columns(columns, varNames)
```
will return output "meta" that has "T" and "Tmean" fields, but not a "P" field.

If you only request a single variable, then "meta" will be a structure whose fields are the dimensions for the variable. For example, if I do:
```matlab
columns = 1:5;
meta = ensMeta.columns(columns, 'T')
```
then "meta" will be a structure with a "lat", "lon", and "time" field.

### Query specific dimensions

You can query metadata for specific dimensions using the third input
```matlab
meta = ensMeta.columns(columns, varNames, dims)
```
Here, "dims" is a string vector listing dimensions of the variables. If you list a single variable and a single dimension, then "columns" will return the metadata directly as an array. For example, if I do:
```matlab
columns = 1:5;
latMeta = ensMeta.columns(columns, 'T', 'lat')
```
then "latMeta" will be an array with 5 rows. Each row contains latitude metadata for one of the queried ensemble members.

If you specify multiple dimensions, or multiple variables, then "meta" will be one of the structure outputs, but will only hold metadata for the specified dimensions. For example, if I do:
```matlab
columns = 1:5;
dims = ["lat", "lon"]
meta = ensMeta.columns(columns, 'T', dims)
```
then "meta" will be a structure with a "lat" and a "lon" field, but it will not have a "time" field.

If you would like to query different dimensions for different variables, the syntax becomes:
```matlab
meta = ensMeta.columns(columns, varNames, dimCell)
```
Here, dimCell is a cell vector with one element per specified variable. Each element holds a string vector listing the dimensions that should be queried for each variable. For example, I could do:
```matlab
columns = 1:5;
varNames = ["T", "P"];
dimCell = { ["lat", "lon"], ["lon", "time"] };
meta = ensMeta.columns(columns, varNames, dimCell)
```
Here, "meta" will be a structure with a "T" field and a "P" field and each field will hold a structure. The "T" structure will have a "lat" and a "lon" field:
```matlab
meta.T.lat
meta.T.lon
```
while the "P" field will have a "lon" and a "time" field:
```matlab
meta.P.lon
meta.P.time
```

### Always return output in the same format
When writing scripts, it can be useful to always return outputs that use the same format. You can use the fourth input to indicate that "columns" output should always use the same format:
```matlab
meta = ensMeta.columns(columns, varNames, dims, fullStruct)
```
Here, fullStruct is a logical that indicates that output should always use the nested structure format. This is the format where the fields of the "meta" output are variable names, and where each field holds a secondary structure with the metadata for dimensions of the variable. Set it to true to ensure that the "meta" output always uses this format. For example, the line:
```matlab
columns = 1:5;
meta = ensMeta.columns(columns, 'T', 'lat', true)
```
will return "meta" as a structure with a "T" field rather than as an array of latitude metadata.
