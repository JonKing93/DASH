---
layout: simple_layout
title: Design Dimensions
---

# Select ensemble and state dimensions

Use the "design" method to specify variable dimensions as state or ensemble dimensions. (For a refresher on state and ensemble dimensions, please see the [concepts page](concepts)). To do this, provide the name of the variable, the name of the dimension, and indicate the type of the dimension. To specify a state dimension, you can use any of:
```matlab
sv = sv.design('myVariable', 'dimensionName', 'state')
sv = sv.design('myVariable', 'dimensionName', 's')
sv = sv.design('myVariable', 'dimensionName', true)
```

To set an ensemble dimension, use any of:
```matlab
sv = sv.design('myVariable', 'dimensionName', 'ensemble')
sv = sv.design('myVariable', 'dimensionName', 'ens')
sv = sv.design('myVariable', 'dimensionName', 'e')
sv = sv.design('myVariable', 'dimensionName', false)
```

Note that when a variable is first added to a state vector, all dimensions are set as state dimensions. Thus, you only need to specify a dimension as a state dimension when you want to provide state indices.

# Specify state or reference indices

(For a refresher on state and reference indices, see the [dimension indices page](dimension-indices)). By default, state vector uses every index along a .grid file dimension as state or reference indices. However, you can use the fourth input to specify a different set of indices: this may either be a vector of linear indices, or a logical vector the length of the dimension in the .grid file. The following lines:
```matlab
sv = sv.design('myVariable', 'dimensionName', 'state', indices)
sv = sv.design('myVariable', 'dimensionName', 'ensemble', indices)
```
specify state indices and reference indices, respectively.

# Design multiple dimensions at once

You design multiple dimensions at the same time by providing a string vector of dimension names as the second argument. When this is the case, using 'state', 's', or true as the third argument will set all listed dimensions as state dimensions. Likewise, using 'ensemble', 'ens', 'e', or false as the third argument will set all list dimensions as ensemble dimensions.
```matlab
dims = ["lat","lon","time","run"];

% Set all dimensions as state dimensions
sv = sv.design('myVariable', dims, 'state')

% Set all dimensions as ensemble dimensions
sv = sv.design('myVariable', dims, false)
```

If you would like to use different settings for different dimensions, use a string or logical vector with one element per dimension listed in dims. For example:
```matlab
dims = ["lat","lon","time","run"];

% Use different settings with a string vector
type = ["state","state","ens","ens"];
sv = sv.design('myVariable', dims, type);

% Use different settings with a logical vector
type = [true true false false];
sv = sv.design('myVariable', dims, type);
```
either of these approaches would specify 'lat' and 'lon' as state dimensions, and 'time' and 'run' as ensemble dimensions.

# Specify indices for multiple dimensions

If you would like to specify state or reference indices for multiple dimensions, then the fourth argument should be a cell vector with one element per listed dimension. Each element should hold the indices for the corresponding dimension. Use an empty array to use the default of all indices for a dimension. For example:
```matlab
dims = ["lat","lon","time","run"];
indices = {49:96, [], 1:12:12000, []}
sv = sv.design('myVariable', dims, type, indices);
```
would use elements 49 to 96 along the latitude dimension, all elements along the longitude dimension, every 12th element along the time dimension, and every element along the run dimension.

[Previous](add)   [Next](sequence)