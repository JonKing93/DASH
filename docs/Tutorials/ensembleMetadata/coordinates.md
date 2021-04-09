---
layout: simple_layout
title: Coordinates
---

# Latitude-Longitude Coordinates

It is often useful to obtain a latitude-longitude coordinate for each element in a state vector. For example, this is usually required when implementing a covariance localization scheme. However, the metadata for spatial coordinates can be split over multiple dimensions, such as the "lat", "lon", and "coord" dimensions, which can be tricky to navigate. Consequently, ensembleMetadata objects provide a "coordinates" command that allow you to collect lat-lon metadata all at once. Simply use
```matlab
latlon = ensMeta.coordinates;
```
to return them. Here, latlon is a numeric matrix with two columns and one row per state vector element. The first column contains the latitude coordinate for each state vector element, and the second column contains the longitude coordinate for each element.

# Behavior and Differences from ensembleMetadata.dimension

The "coordinates" method is built specifically with covariance localization in mind. Consequently, it behaves differently from the "dimension" command is many ways. To begin, the "coordinates" method will **always** return a numeric matrix with two columns. It will not return a structure array or any other metadata formats. To accommodate this, there are several additional changes to the method's behavior.

1. If a variable has *both* "coord" and "lat"/"lon" metadata, or "lat" but not "lon" metadata, its coordinates will be returned as NaN.

2. If a variable uses a spatial mean over the "lat", "lon", or "coord" dimensions, its coordinates will be returned as NaN.

3. If not using  "coord" metadata, then the metadata for each the "lat" and "lon" dimensions must be numeric with a single column. If not, coordinates for the variable will be returned as NaN.

4. If using "coord" metadata, then it must be numeric with two columns. If not, coordinates for the variable will be returned as NaN.

5. When using "coord" metadata, the method will attempt to automatically detect which column is latitude and which is longitude. If it cannot decide, it will use the first column as latitude.

# Notifications

Given these differences in behavior, the "coordinates" method with print a notification message to the console anytime it uses NaN coordinates for a variable. It will also display notifications when deciding which column of "coord" metadata is which. These notifications are enabled by default, but you can disable them using the first input to the "coordinates" command.
```matlab
latlon = ensMeta.coordinates(verbose)
```
Here, "verbose" is a scalar logical. To disable notifications, set it to false, as per:
```matlab
latlon = ensMeta.coordinates(false);
```

[Previous](dimension)---[Next](variable)
