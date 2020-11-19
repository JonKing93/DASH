---
layout: simple_layout
title: Latitude-Longitude Coordinates
---

# Latitude-Longitude coordinates

You can obtain latitude-longitude coordinates for each element down a state vector using the "latlon" command. This is often useful for implementing covariance localization. This command differs from the "dimension" command in several ways. One key difference is that the "latlon" method will attempt to extract latitude-longitude coordinates from the "lat", "lon", or "coord" dimensions as appropriate. Furthermore, the "latlon" command will always return a two-column matrix with one row per state vector element. The first column contains the latitude coordinate for each point, and the second column holds the longitude coordinate for each point.

For example, say I have a state vector that has a "T" variable with 1000 elements, a "Tmean" variable with 1 element, and a "P" variable with 1000 elements. Latitude and longitude metadata for the "T" and "Tmean" variables are stored along the "lat" and "lon" dimensions. However, the latitude and longitude metadata for the "P" variable is stroed along the "coord" dimension. The line:
```matlab
meta = ensMeta.latlon;
```
will return a matrix with 2 columns and 2001 rows. The first column will hold latitude coordinates, and the second column will hold longitude coordinates. Assuming certain requirements are met, then the first 1001 rows (those for "T" and "Tmean") will have latitude-longitude coordinates extracted from the "lat" and "lon" dimensions, while rows 1002 through 2001 (those for "P") will have latitude-longitude coordinates extracted from the "coord" dimension.

### Requirements

This method has several requirements to extract latitude-longitude coordinates for a variable. When these requirements are not met, the method returns NaN coordinates for each row of the variable and notifies the console.

##### Variable Dimensions
First, the variable must have either "lat" and "lon" metadata, or "coord" metadata. It cannot have: only one of "lat" and "lon"; both "lat" and "coord"; or none of "lat", "lon", and "coord".

##### Metadata format
Second, "lat" and "lon" metadata must be numeric and have a single column, while "coord" metadata must be numeric and have exactly two columns. If the variable's metadata does not use one of these formats, then the method will return NaN coordinates for each row of the variable.

When using "coord" metadata, the "latlon" method will attempt to automatically detect the latitude and longitude columns automatically and will notify the console of its choice. If the method cannot distinguish the latitude and longitude column of the "coord" metadata, then it will select the first column as latitude and notify the console.

##### Spatial means
Finally, if a variable takes a mean over the "lat", "lon", or "coord" dimension, then the method will return NaN coordinates for each row of the variable. This occurs because the variable extends over a range of spatial coordinates thus does not have a well-defined latitude-longitude coordinate. \

<br>
### Coordinates for a single variable

You can alternatively return latitude-longitude coordinates for a single variable by specifying the variable's name as the first input:
```matlab
meta = ensMeta.latlon(varName)
```
Here, "meta" is still a 2 column matrix of latitude-longitude coordinates, but will only have one row per state vector element for the variable. Continuing the earlier example:
```matlab
meta = ensMeta.latlon("P")
```
will return a matrix with 1000 rows and two columns.

### Disable console notifications.

By default, the "latlon" method will notify the console whenever it uses NaN coordinates for a variable and when it attempts to detect latitude and longitude columns in "coord" metadata. You can disable these notifications using the second input
```matlab
meta = ensMeta.latlon(varName, verbose)
```
Here, "verbose" is a logical indicating whether to display console notifications. Set it to false to disable notifications. Note that you can use an empty array for the "varName" input to return coordinates for the entire state vector. For example:
```matlab
meta = ensMeta.latlon([], false)
```
would return coordinates for all variables without displaying console notifications.

[Previous](dimension)---[Next](closestLatLon)
