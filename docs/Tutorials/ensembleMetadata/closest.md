# Closest latitude-longitude coordinates

It is often useful to find elements in a state vector variable that are closest to a set of latitude-longitude coordinates. This commonly occurs when selecting inputs for proxy system models. You can use the "closestLatLon" method to do this. Here, the most basic syntax is:
```matlab
rows = ensMeta.closestLatLon( coordinate )
```
Here, "coordinate" is a vector with two elements. The first element is the latitude coordinate, and the second element is the longitude coordinate. The output "rows" list the state vector row that is closest to this coordinate as computed via a haversine function.

For example, say I want to find the state vector rows closest to the 36N and 270W. Then I could do:
```matlab
coordinate = [36 270];
row = ensMeta.closestLatLon(coordinate)
```
to find the state vector row closest to this spatial coordinate.

Similarly, if I want to find the row closest to 36S and 120E, then I could do:
```matlab
coordinate = [-36 -120];
row = ensMeta.closestLatLon(coordinate);
```

Note that you can use (-180 to 180) and (0 to 360) longitude coordinate systems interchangeably as the coordinate system does not affect the haversine distance function. You can even search for a (-180 to 180) coordinate that is closest to a (0 to 360) coordinate and vice versa without error.

### Search a specific variable

Often, a state vector will contain multiple variables, but you need a specific variable to run a PSM. You can use the second input to search for the closest row within a certain variable:
```matlab
rows = ensMeta.closestLatLon(coordinate, varName)
```
where varName is a string that lists a variable in the state vector.

For example, say I have a state vector with variables "T", "Tmean", and "P". I need to use the "P" variable to run a proxy system model for a proxy site at 36N and 270W. Then I could do:
```matlab
coordinate = [36 270];
row = ensMeta.closestLatLon(coordinate, "P")
```
to search for the closest state vector element within the "P" variable.

If you want to verify that "closestLatLon" did return a close coordinate, you can query the metadata at this row using the [rows command](rows).

### Multiple closest rows

If multiple state vector elements are tied as closest to the coordinate, then "closestLatLon" will return a vector that lists the rows of each of those elements. This most often occurs in state vector variables that use a sequence for an ensemble dimension. Continuing the example, say that the "P" variable implements a sequence of four months (May, June, July, and August). Each of those months will have a coordinate at 35N, 265W. Then in the line:
```matlab
coordinate = [36 270];
rows = ensMeta.closestLatLon(coordinate, "P")
```
the "rows" output will have four rows. Each will be the index of one of the months at the closest gridpoint.

In some cases, you may want to further distinguish between the closest state vector elements. You can use the [rows command](rows) to do so.

### Exclude rows from consideration

In some cases, you may want to exclude certain rows from consideration in the search for the closest data element. This can occur if a state vector ensemble contains NaN elements and you want to return the closest rows that have data. You can exclude rows from the search using the third input:
```matlab
rows = ensMeta.closestLatLon(coordinate, [], exclude);  % To search the entire state vector
rows = ensMeta.closestLatLon(coordinate, varName, exclude); % To search a specific variable
```
Here, "exclude" is a logical matrix with either:
1. One row per state vector element, or
2. One row per state vector element for the specified variable

as appropriate.

Any true elements in "exclude" will be removed from the search for the closest coordinate. For example, if I have a state vector with 1000 elements, then I could do:
```matlab
exclude = false(1000,1);
exclude([2, 5, 17]) = true;
rows = ensMeta.closestLatLon(coordinate, [], exclude);
```
to remove the second, fifth, and seventeenth state vector elements from consideration when searching for the closest coordinate.

The "exclude" argument can also have multiple columns. If this is the case, the search is repeated once for each column; each new search will exclude the rows indicated in the corresponding column. This can be useful if a prior has NaN values in different rows of different ensemble members. For example, if I want to find the closest non-NaN elements in a state vector ensemble, I could do:
```matlab
ens = ensemble("my-ensemble.ens");
[X, ensMeta] = ens.load;

exclude = isnan(X);
rows = ensMeta.closestLatLon(coordinate, [], exclude);
```
Here, the "rows" output will be a matrix; each column will hold the closest rows for the corresponding column of "exclude". So in the previous example, "rows" will hold the closest non-NaN rows for each ensemble member.

### Metadata requirements and NaN coordinates

The "closestLatLon" method is designed to search for latitude-longitude coordinates within state vector metadata. If the method cannot determine a coordinate for a state vector element, then the method considers the coordinate to be NaN and notifies the console. The method has the following behavior regarding NaN coordinates.

1. A variable must have *either* "lat" and "lon" metadata *or* "coord" metadata. If the variable does not have exactly one of these requirements, then its state vector elements are given NaN coordinates.

2. Variable metadata for "lat" and "lon" must have a single column. Metadata for "coord" must have two columns. If this requirement is not followed, then NaN coordinates are used for the variable.

**Note**: If using "coord" metadata, the method will attempt to determine which column is latitude and which is longitude; if it cannot decide, it will default to using the first column as latitude.

3. If a variable uses a spatial mean over the "lat", "lon", or "coord" dimensions, then its coordinate is not well-defined and "closestLatLon" will use a NaN coordinate.

If any of these requirements do not work well with your workflow, you can use the [variable](variable), and [findRows](find-rows) commands to find the closest rows manually.



### Disable console notifications

The "closestLatLon" method will display notification messages when using NaN coordinates and detecting latitude-longitude data from "coord" metadata. You can disable these notifications using the fourth output:
```matlab
rows = ensMeta.closestLatLon(coordinate, varName, exclude, verbose)
```
Here, "verbose" is a scalar logical that indicates whether to display console notifications. Set it to false to disable console messages. For example:
```matlab
coordinate = [36 270];
rows = ensMeta.closestLatLon(coordinate, "P", [], false);
```
will not display console notifications.
