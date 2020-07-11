---
layout: simple_layout
title: "Add Sources"
---

# Add data sources to a .grid file

#### Define Source File Metadata
In order to add a data source file to a .grid file, we will need to define the metadata for the data source. This way, the .grid file can locate the data source within the N-dimensional array. We've already seen how to use "gridfile.defineMetadata" to define metadata for an array, and we will use it again here:
```
sourceMeta = gridfile.defineMetadata(sourceDim1, sourceMeta1, sourceDim2, sourceMeta2, ..., sourceDimN, sourceMetaN)
```
as before, the order in which you provide dimensions does not matter. However, the metadata format for each dimension should have the same format as the metadata in the .grid file. For example, if the .grid file uses decimal year time metadata, then you should define time metadata for the source files using a decimal year format.

<br>
#### Add Source File
To add data source files to the .grid file's collection, use
```matlab
grid.add(type, filename, variable, dimensionOrder, sourceMeta)
```
* type specifies the type of data source -- "nc" for NetCDF files, or "mat" for Matlab .mat files.
* filename is the name of data source file.
* variable is the name of the variable as it is saved in the data source file.
* dimensionOrder is the order of the dimensions of the variable in the data source file.
* sourceMeta is the data source file metadata defined above.

If the file name includes a path (for example "\Users\filepath\myfile.nc"), then the matching file is added to the .grid file. If you do not include a path (for example, "myfile.nc"), then the method will search the Matlab active path for a file with the matching name.

The following is an example of a typical workflow:
```matlab
type = 'nc';
filename = 'my-data-file.nc';
variable = 'tas';
dimensionOrder = ["lon","lat","time"];
sourceMeta = gridfile.DefineMetadata("lon", lonMeta, "lat", latMeta, "time", timeMeta);
grid.add(type, filename, variable, dimensionOrder, sourceMeta);
```

**Important Note:** .grid files record the absolute file path of data source files. If you move or rename data source files after adding them to a .grid file, see how to [rename them in the .gridfile](\DASH\gridfile\rename-sources).

<br>
### Non-Regular Grids (Tripolar, Irregular Locations)
Gridfile organizes data using a regular grid; every dimension element is associated with a unique metadata value. However, not all datasets use regular grids. For example, tripolar grids are common in climate models and apply a unique latitude and longitude coordinate to each grid. Similarly, data from irregularly spaced locations (such as instrumental recording stations, or field sites) are also described by a unique latitude and longitude coordinate. You can use the "coord" dimension to organize non-regular spatial data. When defining "coord" metadata, one possibility is to use a two column matrix where the first column denotes the latitude coordinate, and the second column denotes the longitude coordinate.

Often, non-regular data will still be saved with a latitude and a longitude dimension. For example, say we have tripolar climate model output. This output is saved as (longitude x latitude x time). Longitude metadata for this output (lonMeta) is given as an (nLon x nLat) matrix. The latitude metadata for the output (latMeta) is also an (nLon x nLat) matrix. To define metadata for this data source, we can do:
```matlab
coord = [lat(:), lon(:)];
sourceMeta = gridfile.defineMetadata('coord', coord, .., ..);
```
Since we have combined the latitude and longitude metadata into a single "coordinate" metadata, we will need to merge the latitude and longitude dimensions when we add the data source file to the .grid file. To do this, we can use:
```matlab
dimensionOrder = ["coord", "coord", "time"];
grid.add(type, filename, variable, dimensionOrder, sourceMeta);
```
This combines the first two dimensions (lon and lat) of the variable in the data source into a single "coord" dimension. Note that this feature is not limited to the "lat", "lon", and "coord" dimensions. In general, any number of dimensions in a data source file can be merged into a single dimension by specifying the same dimension name multiple times in the dimension order for the add operation.

<br>

#### Optional: Convert Units
You can optionally have the .grid file convert the units of data values loaded from a particular data source. Gridfile converts units using a linear transformation: Y = aX + b, where X are the values loaded from a data source file and Y are the values returned to the user. To convert the units of values from a data source, use the optional 'convert' flag, as per:
```matlab
grid.add(type, filename, variable, dimensionOrder, sourceMeta, 'convert', convert)
```
Here the convert input is a two element vector. The first element specifies the multiplicative constant (a), and the second element specifies the additive constant (b).

<br>

#### Optional: Fill Values and Valid Range
You can have the .grid file convert data matching a fill value to NaN using the optional 'fill' flag
```matlab
grid.add(type, filename, variable, dimensionOrder, sourceMeta, 'fill', fillValue);
```
You can also have the .grid file convert data outside of a valid range to NaN using the optional 'validRange' flag
```matlab
grid.add(type, filename, variable, dimensionOrder, sourceMeta, 'validRange', validRange);
```
Here validRange is a two element vector. The first element is the lower bound of the range and the second element is the upper bound.


[Previous](\DASH\gridfile\object) [Next](\DASH\gridfile\load)
