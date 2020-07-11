---
layout: simple_layout
title: "Add Dimensions"
---

# Add New Dimensions
It's possible that your dataset has more dimensions that the 7 dimensions included by default. If this is the case, you may want to add more dimensions to gridfile. To do this, edit the "dash.dimensionNames" method via
```matlab
edit dash.dimensionNames
```

You should see the following function
```matlab
function[dims, lon, lat, coord, lev, time, run, var] = dimensionNames
%% Returns the names of recognized dimensions in the dash framework.

% Specify the names
lon = "lon";
lat = "lat";
coord = "coord";
lev = "lev";
time = "time";
run = "run";
var = "var";

% Make a list of all the names
dims = [lon, lat, coord, lev, time, run, var];

end
```

You will need to change this function in three places to add a new dimension name.
1. Specify the name of a new dimension in the last of names
2. Add the new dimension to the "dims" array.
3. Add the new dimension to the function output.

Use the following template

```matlab
function[dims, lon, lat, coord, lev, time, run, var, myNewDim] = dimensionNames
%% Returns the names of recognized dimensions in the dash framework.

% Specify the names
lon = "lon";
lat = "lat";
coord = "coord";
lev = "lev";
time = "time";
run = "run";
var = "var";
myNewDim = "newName"

% Make a list of all the names
dims = [lon, lat, coord, lev, time, run, var, myNewDim];

end
```
