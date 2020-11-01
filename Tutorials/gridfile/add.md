---
layout: simple_layout
title: "Add Data Sources"
---

# Add data sources to a .grid file

### Define Source File Metadata
In order to add a data source file to a .grid file, we will need to define the metadata for the data source. This way, the .grid file can locate the data source within the N-dimensional array. We've already seen how to use "gridfile.defineMetadata" to define metadata for an array, and we will use it again here:
```matlab
sourceMeta = gridfile.defineMetadata(sourceDim1, sourceMeta1, sourceDim2, sourceMeta2, ..., sourceDimN, sourceMetaN)
```
As before, the order in which you provide dimensions does not matter. However, the metadata format for each dimension should have the same format as the metadata in the .grid file. For example, if the .grid file uses decimal year time metadata, then you should define time metadata for the source files using a decimal year format.

<br>

### Add Source File
To add data source files to the .grid file's collection, use
```matlab
grid.add(type, filename, variable, dimensionOrder, sourceMeta)
```
* type specifies the type of data source -- <span style="color:#cc00cc">"nc"</span> for NetCDF files, or <span style="color:#cc00cc">"mat"</span> for Matlab .mat files.
* filename is the name of data source file.
* variable is the name of the variable as it is saved in the data source file.
* dimensionOrder is the order of the dimensions of the variable in the data source file.
* sourceMeta is the data source file metadata defined above.

If the file name includes a complete file path (for example "C:\Users\filepath\myfile.nc"), then the matching file is added to the .grid file. If you do not include a path (for example, "myfile.nc") or use a partial path (\filepath\myfile.nc), then the method will search the Matlab active path for a file with the matching name.

The following is an example of how to add one data source:
```matlab
type = 'nc';
filename = 'my-data-file.nc';
variable = 'tas';
dimensionOrder = ["lon","lat","time"];
sourceMeta = gridfile.defineMetadata("lon", lonMeta, "lat", latMeta, "time", timeMeta);
grid.add(type, filename, variable, dimensionOrder, sourceMeta);
```

In practice, we often want to add multiple data source files to a .grid file, so let's use a more realistic example. Say I run a climate model three times. The output for each run is split into two parts: time period A covers the first 1000 time steps, and time period B covers the following 250 time steps. The data is saved as variable 'T' and organized as longitude by latitude by time. Adding these files to a .grid file might look like:
```matlab
files = ["run1-A.nc", "run1-B.nc", "run2-A.nc", "run2-B.nc", "run3-A.nc", "run30B.nc"];
lat = ncread(files(1), 'lat');
lon = ncread(files(2), 'lon');
dimOrder = ["lon","lat","time"];
variable = "T";

% Add each file using a loop
for f = 1:numel(files)

    % Get the run and time metadata for the file
    run = ceil(f/2);
    if rem(f,2) == 1   
        time = time(1:1000);  % Time period A
    else
        time = time(1001:1250);  % Time period B
    end

    % Define metadata for the data source. Add to .grid file
    meta = gridfile.defineMetadata('lat', lat, 'lon', lon, 'time', time, 'run', run);
    grid.add('nc', files(f), variable, dimOrder, meta);
end
```


<br>

### Data source file paths

By default, .grid files save the relative path between the .grid file and data source files. This way, you can move saved .grid files and data sources files to new machines or new directories, so long as you maintain the same relative path. One exception occurs for data source files on a different drive than the .grid file. In this case, there is no relative path, so the .grid file stores the absolute path to the data source. If you would like to move data source files without moving the .grid file or vice versa, see how to [update data source file paths](rename-sources). Alternatively, [save the absolute file path](#optional-save-absolute-file-paths).

<br>

### Non-Regular Grids (Tripolar, Irregular Locations)
Gridfile organizes data using a regular grid; every element along a dimension is associated with a unique metadata value. However, not all datasets use regular grids. For example, tripolar grids are common in climate models and apply a unique latitude and longitude coordinate to each grid cell. Similarly, data from irregularly spaced locations (such as field sites, or instrumental recording stations) usually have a unique latitude and longitude coordinate.

You can use the "coord" (i.e. coordinate) dimension to organize metadata for non-regular spatial grids. This provides an alternative to the "lat" and "lon" dimensions, which require regular latitude and longitude points. One common format for "coord" metadata is a two column matrix where one column holds latitude metadata and one column holds longitude data. This way, each row of the "coord" metadata indicates a unique latitude-longitude point. However, the metadata format is ultimately up to you; use any format you find useful.

Let's look at a few examples to illustrate how to use the "coord" dimension:

##### Example 1: Field sites
Let's say I have a matrix of data representing measurements at various field sites. The matrix is (site x time): each row has the measurements from one field site and each column has the measurement at a particular point in time. The field sites are not on a regular grid, but each site is associated with a unique latitude-longitude coordinate. Consequently, we can use the "coord" dimension to organize the spatial metadata for each site (the rows of the data matrix). For example, say the latitudes of the sites are a column vector named "latitude", and the longitudes are a column vector named "longitude". There is also a vector of time metadata named "time". Then you could do:

```matlab
coord = [latitude, longitude];
sourceMeta = gridfile.defineMetadata('coord', coord, 'time', time);
dimensionOrder = ["coord", "time"];
grid.add(type, filename, variable, dimensionOrder, sourceMeta);
```

##### Example 2: Tripolar data

Let's say I have tripolar climate model. Although tripolar grids do not use regular latitude or longitude points, tripolar model output often still has an explicit longitude and latitude dimension. In this example, let's say my tripolar data is (longitude x latitude x time). Longitude metadata (lon) is an (nLon x nLat) matrix. The latitude metadata (lat) is also an (nLon x nLat) matrix. Note that the latitude and longitude metadata are matrices rather than vectors because the tripolar grid is not regular and each spatial point is associated with a unique latitude-longitude coordinate.

Since each spatial point is associated with a unique latitude-longitude coordinate, we will want to use the "coord" dimension to organize spatial metadata. As in example 1, we want each row of the "coord" metadata to define a unique latitude-longitude coordinate, so we would do:
```matlab
coord = [latitude(:), longitude(:)];
```

However, there is a difference from Example 1 when adding this tripolar data source into the .grid file. In example 1, the "coord" dimension clearly corresponded to the data dimension for the field sites. However, in example 2, the "coord" dimension corresponds to two data dimensions (the longitude and the latitude dimension). Consequently, we will need to merge the data source's latitude and longitude dimensions. We can do this by using "coord" for both dimensions in the data source. For example:
```matlab
dimensionOrder = ["coord", "coord", "time"];
```
would merge the first two data dimensions (latitude and longitude) into a single coordinate dimension. The third dimension will remain the time dimension. Putting it all together, you can use the following framework to add a tripolar data source:
```matlab
coord = [latitude(:), longitude(:)];
sourceMeta = gridfile.defineMetadata('coord', coord, 'time', time);
dimensionOrder = ["coord", "coord", "time"];
grid.add(type, filename, variable, dimensionOrder, sourceMeta);
```

<br>
**Note:** Merged dimensions should have the same _relative_ dimension order in data source files. So, if longitude comes before latitude in a data source's dimension order, it should come before latitude in other data sources. For example, if I am merging lon and lat, then:
* Data Source 1: Lon x Lat x Time, and
* Data Source 2: Lon x Time x Lev x Lat

would be fine because "lon" comes before "lat" in both data sources. However,

* Data source 1: Lon x Lat x Time, and
* Data source 2: Lat x Lon x Time

would not because "lon" comes before "lat" in one source, but after "lat" in another source.

<br>

### Optional: Convert Units
You can optionally have the .grid file convert the units of data values loaded from a particular data source. Gridfile converts units using a linear transformation: Y = aX + b, where X are the values loaded from a data source file and Y are the values returned to the user. To convert the units of values from a data source, use the optional 'convert' flag, as per:
```matlab
grid.add(type, filename, variable, dimensionOrder, sourceMeta, 'convert', convert)
```
Here the convert input is a two element vector. The first element specifies the multiplicative constant (a), and the second element specifies the additive constant (b). So, if I want data stored in units of Kelvin converted to units of Celsius, I would do:
```matlab
convert = [1, -273.15];
grid.add(type, filename, variable, dimensionOrder, sourceMeta, 'convert', convert);
```
Note that the first element of convert is 1 because it is the multiplicative constant and we do not need multiplication to convert from Kelvin to Celsius. By contrast, if I wanted to convert data stored in Fahrenheit to Celsius, I could do:
```matlab
convert = [5/9, -32*(5/9)];
grid.add(type, filename, variable, dimensionOrder, sourceMeta, 'convert', convert);
```

<br>

### Optional: Fill Values and Valid Range
You can have the .grid file convert data matching a fill value to NaN using the optional 'fill' flag:
```matlab
grid.add(type, filename, variable, dimensionOrder, sourceMeta, 'fill', fillValue);
```

For example, if a data source file uses -9999 as a fill value, I would do
```matlab
grid.add(type, filename, variable, dimensionOrder, sourceMeta, 'fill', -9999);
```
to convert -9999 to NaN when data is loaded.

You can also have the .grid file convert data outside of a valid range to NaN using the optional 'validRange' flag:
```matlab
grid.add(type, filename, variable, dimensionOrder, sourceMeta, 'validRange', validRange);
```
Here validRange is a two element vector. The first element is the lower bound of the range and the second element is the upper bound. For example, if I know my data should be positive, but no larger than 100, I could do
```matlab
grid.add(type, filename, variable, dimensionOrder, sourceMeta, 'validRange', [0 100]);
```
to convert any values smaller than 0 or larger than 100 to NaN when data is loaded.

<br>

### Optional: Save Absolute File Paths

When you add a data source file to a .grid file, the relative path from the .grid file to the data source is added to the .grid file's collection by default. However, you may want to save the absolute path to a data source file if you anticipate moving the .grid file but not the data source. To do so, use the 'absolutePath' flag and select true as the option:
```matlab
grid.add(type, filename, variable, dimensionOrder, sourceMeta, 'absolutePath', true)
```


[Previous](object)---[Next](load)
