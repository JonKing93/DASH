---
layout: simple_layout
title: Closest coordinates
---

# Closest latitude-longitude coordinates

It is often useful to find elements in a state vector variable that are closest to a set of latitude-longitude coordinates. This is often useful when selecting inputs for proxy system models. You can use the "closestLatLon" method to do so. Here, the most basic syntax is:
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

For example, say I have a state vector with variables "T", "Tmean", and "P". I need to use the "P" variable to run a proxy system model for a proxy site at 36N and 270W. Let's say the fifth element of "P" is located at 35N and 265W and is the closest to the proxy coordinate. Then I could do:
```matlab
coordinate = [36 270];
row = ensMeta.closestLatLon(coordinate, "P")
```
and the output "row" would be
```matlab
row = 5;
```
I could then use the [findRows](find-rows) command to locate this element within the full state vector
```matlab
stateVectorRow = ensMeta.findRows("P", row)
```
If you want to verify that "closestLatLon" did return a close coordinate, you can obtain the metadata at this row using the [rows command](rows).

### Multiple closest rows

If multiple state vector elements are tied as closest to the coordinate, then "closestLatLon" will return a vector that lists the rows of each of those elements. This most often occurs in state vector variables that use a sequence. Continuing the example, say that the "P" variable implements a sequence of four months (May, June, July, and August). Each of those months will have a coordinate at 35N, 265W. Let's say that those occur in rows 5, 255, 505, and 755 of the "P" variable. Then in the line:
```matlab
coordinate = [36 270];
rows = ensMeta.closestLatLon(coordinate, "P")
```
the output "rows" will be
```matlab
rows = [5; 255; 505; 755];
```

In some cases, you may want to further distinguish between the closest state vector elements. You can use the [rows command](rows) to do so. Continuing the example, let's say that I only want to use data from May to run the PSM. Then I could use the "rows" command to obtain the monthly metadata for each of the closest elements:
```matlab
closestRows = [5; 255; 505; 755];
meta = ensMeta.rows( closestRows );
may = month(meta.time)==5;
mayRow = closestRows(may);
```

Again, I will probably also want to use the [findRows command](find-rows) to locate this row of the "P" variable within the full state vector
```matlab
psmRow = ensMeta.findRows( mayRow );
```

You can find more examples and details of how to implement these functions for proxy system models in the PSM tutorial.

### Behavior and NaN coordinates

The "closestLatLon" method uses the "latlon" method to extract latitude-longitude coordinates from the state vector. Consequently, the method has the same [metadata requirements](latlon#metadata-format) and [behavior regarding NaN coordinates](latlon#nan-coordinates) as the "latlon" method. Furthermore, the haversine function is designed to operate on coordinates expressed in decimal degrees. If any of these conventions do not apply to your workflow, then you can use the [variable](variable) and [findRows](find-rows) commands to find the closest rows manually. You can see an example of how to implement this in the PSM tutorial.

### Disable console notifications

Since the "closestLatLon" method use the "latlon" method, it will also display notification messages when returning NaN coordinates and detecting latitude-longitude data from "coord" metadata. You can disable these notifications using the third output:
```matlab
rows = ensMeta.closestLatLon(coordinate, varName, verbose)
```
Here, "verbose" is a scalar logical that indicates whether to display console notifications. Set it to false to disable console messages. For example:
```matlab
coordinate = [36 270];
rows = ensMeta.closestLatLon(coordinate, "P", false);
```
will not display console notifications.

[Previous](latlon)---[Next](rows)
