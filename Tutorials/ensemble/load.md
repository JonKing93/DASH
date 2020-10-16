---
layout: simple_layout
title: Load Ensemble
---

# Load a saved ensemble

You can use the "load" command to load an ensemble from a .ens file.
```matlab
[X, meta] = ens.load;
```
The two outputs are the state vector ensemble matrix (X), and an ensembleMetadata object for the matrix (meta).

# Load gridded climate variables

You can also use the "loadGrids" command to load gridded climate variables instead of state vectors.
```matlab
s = ens.loadGrids
```
Here, "s" is a structure that contains gridded climate variables and metadata. The fields of "s" will be the names of the loaded climate variables. The field for each variable is also a structure; each contains three fields:

1. data: The gridded variable. Note that ensemble members will always be along the last dimension,
2. gridMetadata: Metadata along the dimensions of the gridded variable, and
3. members: Metadata for the ensemble members of the gridded ensemble.

For example, say I have a state vector ensemble with variables "T", "Tmean", and "P". The "time" and "run" dimensions are ensemble dimensions, and the time dimension uses a sequence. The "lat" and "lon" dimensions are state dimensions. In this case, the output "s" will have three fields: "T", "Tmean", and "P". Each of these fields will have the three fields "data", "gridMetadata", and "members", such that:
```matlab
s.T.data
```
would be the gridded "T" variable with ensemble members along the last dimension.
```matlab
s.T.gridMetadata
```
would contain regridded metadata along the state vector. For example,
```matlab
s.T.gridMetadata.lat
s.T.gridMetadata.lon
s.T.gridMetadata.time
```
would have the lat, lon, and time sequence metadata for the regridded variable.

Finally,
```matlab
s.T.members
```
would have metadata for the ensemble members of the "T" variable. For example,
```matlab
s.T.members.time
s.T.members.run
```
would have time and run metadata for the ensemble members.

[Previous](object)---[Next](subset)
