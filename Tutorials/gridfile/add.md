---
layout: simple_layout
title: "Add Data Sources"
---

# Add data sources to a .grid file

* [Define source file metadata](#define-source-file-metadata)
* [Add source files](#add-source-files)
  * [Example 1](#example-1)
  * [Example 2](#example-2)
* [Data source filepaths](#data-source-filepaths)
* [Merging Dimensions (for tripolar grids)](#merging-dimensions-tripolar-grids)
* [Optional: Convert Units](#optional-convert-units)
* [Optional: Fill value and valid range](#optional-fill-value-and-valid-range)
* [Optional: Absolute file paths](#optional-save-absolute-file-paths)

So, we've have created a .grid file and defined the scope of its N-dimensional array. Returning to the illustrations, we have something like this:

<img src="\DASH\assets\images\gridfile\grid-metadata.svg" alt="An N-dimensional array with metadata." style="width:80%;display:block">

At this point, that N-dimensional array is empty; it is not organizing any data. We want to start adding data source files to the grid so that the N-dimensional array is populated with data:

<img src="\DASH\assets\images\gridfile\grid-source.svg" alt="An N-dimensional array with data source files." style="width:80%;display:block">


### Define Source File Metadata
In order to add a data source file to a .grid file, we first need to define the scope of the data in the data source file. This way, the .grid file can locate the values in the data source within the N-dimensional array. Returning to the illustrations:

<img src="\DASH\assets\images\gridfile\grid-source.svg" alt="An N-dimensional array with data source files." style="width:80%;display:block">

this is the step where we indicate that the data in a file covers spatial coordinates A-B, is for time steps C-D, is from run E, holds data for variable F, etc.

We will return to the ["defineMetadata" command](define) to define the scope of the data in each data source file.

```matlab
sourceMeta = gridfile.defineMetadata(sourceDim1, sourceMeta1, sourceDim2, sourceMeta2, ... sourceDimN, sourceMetaN)
```

As before, the order in which you provide dimensions does not matter. However, the metadata format for each dimension should have the same format as the metadata in the .grid file. For example, if the .grid file uses decimal year time metadata, then you should define time metadata for the source files using a decimal year format.

<br>

### Add Source File
To add data source files to the .grid file's collection, use
```matlab
grid.add(type, source, variable, dimensionOrder, sourceMeta)
```
Here, type specifies the type of data source. The options for type are:
* <span style="color:#cc00cc">"nc"</span>: For NetCDF files.
* <span style="color:#cc00cc">"mat"</span>: For Matlab .mat files, and
* <span style="color:#cc00cc">"opendap"</span>: For data accessed via an OPeNDAP url.

The remaining inputs are as follows:
* source is either the name of the data source file or the OPeNDAP url. It is a string.
* variable is the name of the variable as it is saved ***in the data source file***. This is also a string.
* dimensionOrder is the order of the dimensions of the variable ***in the data source file***.
* sourceMeta is the data source metadata defined above.

If the file name includes a complete file path (for example "C:\Users\filepath\myfile.nc"), then the matching file is added to the .grid file. If you do not include a path (for example, "myfile.nc") or use a partial path (\filepath\myfile.nc), then the method will search the Matlab active path for a file with the matching name.

#### Example 1

The following is an example of how to add one data source to a .grid file (named "my-grid.grid") that organizes a surface temperature variable. The data source file holds monthly data from 1850 to 2000 CE, and the .grid file uses a datetime format for the "time" dimension. The temperature variable is saved under the name "tas" in the data source file.
```matlab
% Define metadata
file = 'my-data-file.nc';
lat = ncread(sourceFile, 'lat');
lon = ncread(sourceFile, 'lon');
time = (datetime(1850,1,15) : calmonths(1) : datetime(2000,12,15))';
sourceMeta = gridfile.defineMetadata('lat', lat, 'lon', lon, 'time', time);

% Add the data source to the .grid file
type = 'nc';
variable = 'tas';  % The name of the variable in the source file
dimensionOrder = ["lon", "lat", "time"];  % The order of the dimensions in the source file
grid = gridfile('my-grid.grid');
grid.add(type, filename, variable, dimensionOrder, sourceMeta)
```

#### Example 2
In practice, we often want to add multiple data source files to a .grid file, so let's use a more realistic example. Say I run a climate model three times. The output for each run is split into two parts: time period A covers the first 1000 time steps, and time period B covers the following 250 time steps. The data is saved as variable 'T' and organized as longitude by latitude by time. Adding these files to a .grid file might look like:
```matlab
files = ["run1-A.nc", "run1-B.nc", "run2-A.nc", "run2-B.nc", "run3-A.nc", "run30B.nc"];
lat = ncread(files(1), 'lat');
lon = ncread(files(1), 'lon');
dimOrder = ["lon","lat","time"];
variable = "T";

% Add each file using a loop
for f = 1:numel(files)

    % Get the run and time metadata for the file
    run = ceil(f/2);
    if rem(f,2) == 1   
        time = (1:1000)';  % Time period A
    else
        time = (1001:1250)';  % Time period B
    end

    % Define metadata for the data source. Add to .grid file
    sourceMeta = gridfile.defineMetadata('lat', lat, 'lon', lon, 'time', time, 'run', run);
    grid.add('nc', files(f), variable, dimOrder, sourceMeta);
end
```


<br>

### Data source file paths

By default, .grid files save the relative path between the .grid file and data source files. This way, you can move saved .grid files and data sources files to new machines or new directories, so long as you maintain the same relative path. One exception occurs for data source files on a different drive than the .grid file. In this case, there is no relative path, so the .grid file stores the absolute path to the data source. If you would like to move data source files without moving the .grid file or vice versa, see how to [update data source file paths](rename-sources). Alternatively, [save the absolute file path](#optional-save-absolute-file-paths).

<br>

### Merging Dimensions (Tripolar grids)

Gridfile organizes data using a regular grid; every element along a dimension is associated with a unique metadata value. However, not all datasets use regular spatial grids. We previously saw [how to use the "coord" dimension](new#example-4-tripolar-data) to define metadata for datasets with non-regular spatial coordinates. However, some non-regular datasets may still be saved with explicit latitude and longitude dimensions. This is most common for tripolar model output: tripolar data is often saved as (longitude x latitude x time) even though each tripolar spatial point has a unique latitude-longitude coordinate. Spatial metadata for such data is typically provided as a latitude *matrix* of size (nLon x nLat) and a longitude *matrix* also of size (nLon x nLat). The spatial coordinate for each spatial point can then be found by querying the appropriate element in each of the latitude and longitude matrices.

Since each spatial point is associated with a non-regular latitude and longitude coordinate, we should use the "coord" dimension to organize the spatial metadata. As we saw previously, we could use something like:
```matlab
file = 'my-tripolar-data.nc';
lat = ncread(file, 'lat');
lon = ncread(file, 'lon');
coord = [lat(:), lon(:)];
time = (1:1000)';  % A random time format...

meta = gridfile.defineMetadata('coord', coord, 'time', time)
```
to specify metadata for a tripolar grid. However, this presents a challenge when adding data source files. The "add" command requires you to specify the order of the dimensions in the data source, but the (longitude x latitude x time) data has no explicit "coordinate" dimension. The solution is to merge the longitude and latitude dimensions into a single "coordinate" dimension by adjusting the 'dimensionOrder' input. Initially, the dimension order for the tripolar data source appears to be:
```matlab
dimensionOrder = ["lon", "lat", "time"];
```

To merge data source dimensions into a single .grid file dimension, replace the names of the merged data source dimensions with the desired grid file dimension. In this example, I want to merge the "lon" and "lat" data dimensions into a single "coord" dimension, so I would do:
```matlab
dimensionOrder = ["coord", "coord", "time"];
```

The full call to gridfile.add might look something like:
```matlab
% Get the source file metadata
file = 'my-tripolar-data.nc';
lat = ncread(file, 'lat');
lon = ncread(file, 'lon');
coord = [lat(:), lon(:)];
time = (1:1000)';  % A random time format...
sourceMeta = gridfile.defineMetadata('coord', coord, 'time', time);

% Add the data source file to the .grid file
type = 'nc';
dimensionOrder = ["coord", "coord", "time"];
variable = 'slp';  % Name of the tripolar variable in 'my-tripolar-data.nc'
grid = gridfile('my-grid.grid');
grid.add(type, file, variable, dimensionOrder, sourceMeta)
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

### Optional: Fill Value and Valid Range
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
