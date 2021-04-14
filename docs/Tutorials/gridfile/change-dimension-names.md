# Change Dimension Names

You may wish to change the name of a dimension to something you find more meaningful. For example, you might want to rename the latitude dimension from <span style="color:#cc00cc">"lat"</span> to <span style="color:#cc00cc">"latitude"</span>. To do this, start by opening the "dash.dimensionNames" method via
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

To change the name of a dimension, change its name here. For example to rename the latitude dimension from <span style="color:#cc00cc">"lat"</span> to <span style="color:#cc00cc">"latitude"</span>, you should change
```matlab
lat = "lat";
```
to
```matlab
lat = "latitude";
```
**Important:**
1. All new dimension names must be [valid Matlab variable names](https://www.mathworks.com/help/matlab/matlab_prog/variable-names.html), and
2. Do not change the order of dimensions in the "dims" array or in the function output (the order of these dimensions is hard-coded into later DASH methods).
