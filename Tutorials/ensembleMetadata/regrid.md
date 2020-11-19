---
layout: simple_layout
title: Regrid
---

# Regrid a state vector

You can use an ensembleMetadata object to reshape a state vector ensemble back into gridded climate variables. Do this using the "regrid" method. The most basic syntax is:
```matlab
[Y, meta] = ensMeta.regrid(X, varName)
```
Here X is a state vector ensemble and varName is the name of a variable in the ensemble. Y is the regridded state vector variable, and meta holds metadata for the regridded dimensions of the variable. Note that the order of the dimensions in "meta" will always match the order of dimensions in the regridded variable.

For example, say I have a state vector ensemble with 75 ensemble members, a "T" variable with 1000 state vector elements, a "Tmean" variable with 1 element, and a "P" variable with 1000 elements. In this case, my state vector ensemble "X" has 2001 rows (state vector elements) and 75 columns (ensemble members). Say the "T" variable was originally an array of size (25 longitudes x 10 latitudes x 4 months). Then in the line:
```matlab
[Y, meta] = ensMeta.regrid(X, "T")
```
the array "Y" is the regridded "T" variable. It will have size (25 longitudes x 10 latitudes x 4 months x 75 ensemble members). The output "meta" is a structure with fields "lon", then "lat", and last "time" (the regridded dimensions). The "lon" field holds an array of longitude metadata with 25 rows, the "lat" field holds an array of latitude metadata with 10 rows, and the "time" field holds an array of monthly time metadata with 4 rows.

### Specify the order of regridded dimensions
If unspecified, the "regrid" command will return the gridded variable with a default dimension order. However, you can use the third input to specify the order of dimensions in the regridded variable:
```matlab
[Y, meta] = ensMeta.regrid(X, varName, dims)
```
Here, dims is a string vector that lists dimensions of the variable. Continuing the example, if I did:
```matlab
dims = ["time", "lat", "lon"];
[Y, meta] = ensMeta.regrid(X, 'T', dims);
```
then output "Y" will have size (4 months x 10 latitudes x 25 longitudes) and the order of the fields in "meta" will be "time", then "lat", then "lon".

Note that you do not need to specify all the dimensions of a variable. Any unspecified dimensions will use a default dimension order. For example I could use:
```matlab
dims = "lat";
[Y, meta] = ensMeta.regrid(X, 'T', dims);
```
This will ensure that "lat" is the first dimension of the regridded state vector, but the order of "lon" and "time" will be determined automatically.

### Specify the state vector dimension
So far, the examples have assumed that the state vector proceeds down the first dimension of the ensemble "X". However, you can use the fourth input to indicate that the state vector proceeds along a different dimension:
```matlab
[Y, meta] = ensMeta.regrid(X, varName, dims, d)
```
where d is a positive integer.

Continuing the example, say I perform three assimilations on the ensemble, each with different settings. I store the output from these assimilations in array "X2" which has size (3 assimilations x 2001 state vector elements x 75 ensemble members). In this scenario, the state vector proceeds along the second dimension, so I would need to use:
```matlab
dims = ["lon", "lat", "lat"];
d = 2;
[Y2, meta] = ensMeta.regrid(X2, 'T', dims, d);
```
Here, the output "Y2" would have size (3 assimilations x 25 longitudes x 10 latitudes x 4 months x 75 ensemble members). Note that the "dims" input only affects the order of the regridded dimensions. So "lon", "lat", and "time" will not appear before the dimension for the 3 assimilations (dimension 1). Instead, the state vector dimension (dimension 2) will be regridded into ("lon" x "lat" x "time").

### Retain singleton dimensions
By default, the "regrid" command will remove singleton dimensions from the regridded variable and its metadata. Changing the example, let's say that "T" was originally an array of size (25 latitudes x 10 longitudes x 1 time step). In this case, the line:
```matlab
[Y, meta] = ensMeta.regrid(X, 'T')
```
will return output "Y" that is (25 longitudes x 10 latitudes x 75 ensemble members), and "meta" with fields "lon" and "lat". The "time" dimension has been removed from the output.

You can retain singleton dimensions using the fifth output
```matlab
[Y, meta] = ensMeta.regrid(X, varName, dims, d, keepSingletons)
```
where "keepSingletons" is a logical indicating whether to retain singleton dimensions. Set it to true to retain singleton dimensions in the output. For example, in line:
```matlab
[Y, meta] = ensMeta.regrid(X, 'T', [], [], true)
```
the output "Y" will now be (25 longitudes x 10 latitudes x 1 time step x 75 ensemble members).

Note that dimensions explicitly listed in the "dims" input will never be removed from the output. So as an alternative, you could use:
```matlab
dims = ["lon","lat","time"];
[Y, meta] = ensMeta.regrid(X, 'T', dims);
```
to ensure that "Y" is (25 longitudes x 10 latitudes x 1 time step x 75 ensemble members). Since the "time" dimension is listed in "dims", it will not be removed from the output, even though it is a singleton dimension.

These sections have detailed several common methods for interacting with variables in a state vector. In the next few sections, we will change focus and see how to query the metadata at any point in a state vector ensemble.

[Previous](sizes)---[Next](find-rows)
