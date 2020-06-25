function[dims, lon, lat, coord, lev, time, run, var] = dimensionNames
%% Returns the names of recognized dimensions in the dash framework.
%
% dims = dash.dimensionNames
% Returns a vector of all recognized data dimension names.
%
% [dims, lon, lat, coord, lev, time, run, var] = dash.dimensionNames
% Returns the names of individual dimensions.
%
% ----- Outputs -----
%
% dims: A string vector containing all recognized dimension names (nNames x 1)
%
% lon: The longitude dimension name
%
% lat: The latitude dimension name
%
% coord: The coordinate dimension name. (Useful for data collections with
%        non-rectangular lon-lat coordinates. For example, a tripolar grid
%        or data for individual proxy sites.)
%
% lev: The level (height) dimension name.
%
% time: The time dimension name.
%
% run: The run (ensemble member) dimension name.
%
% var: The climate variable dimension name.

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