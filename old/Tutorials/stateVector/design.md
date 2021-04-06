---
layout: simple_layout
title: Design Dimensions
---

# Design Method

The "design" method can be used to specify variable dimensions as [state or ensemble dimensions](concepts#state-and-ensemble-dimensions), and to specify [dimension indices](dimension-indices). By default, stateVector treats each dimension as a state dimension and sets the dimension indices to every element along the dimension. Consequently, you do not need to apply the design method to state dimensions that use every element.

# Set ensemble and state dimensions

You can use the design method to set variable dimensions as state or ensemble dimensions. To do this, provide the name of the variable, the name of the dimension, and indicate the type of the dimension. To specify a state dimension, you can use any of:
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

<br>
### Specify state or reference indices

You can use the fourth input to specify dimension indices indices: this may either be a vector of linear indices, or a logical vector the length of the dimension in the .grid file. The following syntax:
```matlab
sv = sv.design('myVariable', 'dimensionName', type, indices)
```
specifies state or reference indices for a dimension. Note that "type" can be any of the inputs used to indicate a state or ensemble dimension.

##### Example 1
Let's say I want to only want to include Northern Hemisphere points for a 'T' variable. Then I could do:
```matlab
grid = gridfile('temperature.grid');
meta = grid.metadata;

nh = lat > 0;
sv = sv.design('T', 'lat', 'state', nh);
```
to set the state indices.

##### Example 2
Let's say I only want to select ensemble members from preindustrial years before 1850. Then I could do:
```matlab
grid = gridfile('temperature.grid');
meta = grid.metadata;

preindustrial = meta.time < 1850;
sv = sv.design('T', 'lat', 'ensemble', preindustrial);
```
to set the reference indices.

<br>
### Design multiple variables at once

You can design multiple variables at the same time by providing a string vector of variable names as the first input. For example
```matlab
vars = ["T","P","Tmean"];
preindustrial = meta.time < 1850;
sv = sv.design(vars, "time", "ensemble", preindustrial);
```
will use the time dimension as an ensemble dimension and specify preindustrial reference indices for each of the "T", "P", and "Tmean" variables.

### Design multiple dimensions at once

You can also design multiple dimensions at the same time by providing a string vector of dimension names as the second argument. When this is the case, using 'state', 's', or true as the third argument will set all listed dimensions as state dimensions. Likewise, using 'ensemble', 'ens', 'e', or false as the third argument will set all listed dimensions as ensemble dimensions. For example:
```matlab
% Set multiple dimensions as state dimensions
dims = ["lat", "lon"];
sv = sv.design('T', dims, 'state');

% Set multiple dimensions as ensemble dimensions
dims = ["time", "run"];
sv = sv.design('T', dims, false)
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

<br>
### Specify indices for multiple dimensions

If you would like to specify state or reference indices for multiple dimensions, then the fourth argument should be a cell vector with one element per listed dimension. Each element should hold the indices for the corresponding dimension. Use an empty array to use the default of all indices for a dimension. For example:
```matlab
% Get dimension indices
nh = meta.lat>0;
preindustrial = meta.time<1850;

% Use the design method
dims = ["lat","lon","time","run"];
type = ["state","state","ensemble","ensemble"];
indices = {nh, [], preindustrial, []}
sv = sv.design('T', dims, type, indices);
```
would use latitude and longitude as state dimension and select Northern Hemisphere points at all longitudes. Likewise, it would set time and run as ensemble dimensions and select ensemble members from preindustrial years in any run.

It's worth noting that we don't actually need to specify the options for the "lon" dimension in this example. Remember that the default setting for all dimensions is a state dimension with all elements selected. Since that's what we use here, we don't actually need to provide it to the "design" method. However, I've left it here to help clarify the example.

<br>
### Coupled variable notification

Sometimes, using the design method on a variable will alter the dimension settings for other variables and a notification will be printed to the console. Don't panic. This is the desired behavior for most assimilations and occurs because of [variable coupling](couple). You can [disable these notifications](notify-console) if you do not want to receive them.

[Previous](add)---[Next](sequence)
