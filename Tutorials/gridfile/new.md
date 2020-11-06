---
layout: simple_layout
title: "New .grid File"
---

# Create a new .grid file

* [Define Metadata](#define-metadata)
  * [Example 1: Basic Use](#example-1-basic-use)
  * [Example 2: Multiple Variables](#example-2-multiple-variables)
  * [Example 3: Irregularly-spaced data](#example-3-irregularly-spaced-data)
  * [Example 4: Tripolar Data](#example-4-tripolar-data)
* [Create File](#create-file)
* [Optional: Include Non-Dimensional Attributes](#optional-include-non-dimensional-attributes)
* [Optional: Overwrite Existing Files](#optional-overwrite-existing-files)

Before creating a new .grid file, let's first recall that each .grid file manages an N-dimensional array:

<img src="\DASH\assets\images\gridfile\grid-empty.svg" alt="An Empty N-dimensional array." style="width:80%;display:block">

In order to create a .grid file, we will first need to define the scope of that array by defining metadata along each of the .grid file's dimensions. Using the previous illustrations as an example:

<img src="\DASH\assets\images\gridfile\grid-metadata.svg" alt="An N-dimensional array with metadata." style="width:80%;display:block">

this is the step where we would specify that the data organized by the .grid file spans latitudes from -90 to 90 in steps of 30 degrees, longitudes from 0 to 270 in steps of 60 degrees, and years 1 through 3 with an annual time step.

## Define Metadata

To define metadata for a .grid file, we will use the ["defineMetadata" command](define).

Recall that the syntax for using the defineMetadata method is:
```matlab
meta = gridfile.defineMetadata(dimension1, metadata1, dimension2, metadata2, ..., dimensionN, metadataN);
```

Dimension names are:
* <span style="color:#cc00cc">"lon"</span> -- for the longitude / x dimension
* <span style="color:#cc00cc">"lat"</span> -- for the latitude / y dimension
* <span style="color:#cc00cc">"coord"</span> -- for non-regular spatial coordinates
* <span style="color:#cc00cc">"lev"</span> -- the level / height / z dimension
* <span style="color:#cc00cc">"time"</span> -- the time dimension
* <span style="color:#cc00cc">"run"</span> -- for individual members of an ensemble
* <span style="color:#cc00cc">"var"</span> -- for different variables on the same spatial/temporal grid

You only need to use dimensions that are relevant for your dataset and you can provide them in any order. Metadata for each dimension must have one row per element along the dimension and each row must be unique. The metadata can use a numeric, logical, string, char, cellstring, or datetime format.


#### Example 1: Basic Use

For a realistic example, let's say I have files "mydata-run1.nc" and "mydata-run2.nc" which store data from two runs of a climate model. Each file has longitude, latitude and time metadata stored within (saved under the names "longitude", "latitude", and "time"), and I find the latitude and longitude values useful. The time metadata is for January 850 to December 2005 with a monthly time step but stored as days since 850-1-1, which I do not find useful. Instead, I would like to use a datetime metadata format. In this case, the metadata definition would be:
```matlab
lat = ncread('mydata-run1.nc', 'latitude');
lon = ncread('mydata-run2.nc', 'longitude');
run = [1;2];
time = (datetime(850,1,15) : calmonths(1) : datetime(2005,12,15))';
meta = gridfile.defineMetadata('lat', lat, 'lon', lon, 'time', time, 'run', run);
```
The metadata structure "meta" defines the scope of an N-dimensional array. If the array is (lon x lat x time x run), it would have a size of (nLon longitudes x nLat latitudes x 13872 time steps x 2 runs).

Note that I read values from an actual data file in order to define .grid file metadata for this example. It is worth noting that this is common in workflows. A .grid file lets you specify whatever metadata you find most convenient for a data set, so if you find the metadata saved in a data file useful, you will want to use it to define the .grid file.

#### Example 2: Multiple variables

Let's use output from CMIP5 for a second example. Say I have output from CCSM4 for the last millennium experiment. It extends from January 850 to December 2005 with a monthly time step. There are three ensemble members, each differing in their initial conditions: these use the "r1i1p1", "r1i2p1", and "r1i3p1" designations. I have output for both surface temperature (the "tas" variable) and precipitation (the "pr" variable). I do not find the "tas" and "pr" abbreviations useful and want to refer to them using the names "Temperature" and "Precipitation". Both variables use the same spatial grid. Then I could use the following metadata definition:

```matlab
outputFile1 = "tas_Amon_CCSM4_past1000_r1i1p1_085001-185012.nc"
lat = ncread(outputFile1, 'lat');
lon = ncread(outputFile1, 'lon');
time = (datetime(850,1,15) : calmonths(1) : datetime(2005,12,15))';
run = ["r1i1p1";"r1i2p1";"r1i3p1"];
var = ["Temperature";"Precipitation"];
meta = gridfile.defineMetadata('var', var, 'run', run, 'lon', lon, 'lat', lat, 'time', time);
```
This would define the scope an N-dimensional array to hold this dataset. If the array is (lon x lat x time x run x var), then the size would be (nLon longitudes x nLat latitudes x 13872 time steps x 3 runs x 2 variables).


#### Example 3: Irregularly-spaced data

Let's say I have data from 54 irregularly-spaced field sites saved in the file 'field-data.mat'. In addition to the field data, the file also has the latitude, longitude, and elevation of each field site saved in the vectors 'lat', 'lon', and elevation. The field data has annual measurements from 1850 CE to 1995 CE. Then the metadata definition could be:
```matlab
file = 'field-data.mat';
coordinates = load(file, 'lat', 'lon', 'elevation');
time = 1850:1995;
coord = [coordinates.lat, coordinates.lon, coordinates.elevation];
meta = gridfile.defineMetadata('coord', coord, 'time', time);
```
If this N-dimensional array is (coord x time), then its size would be (54 sites x 146 years).


#### Example 4: Tripolar Data

Say I have a dataset saved on a tripolar grid. Tripolar grids use non-regular spatial points, so we should use the "coord" dimension to organize spatial metadata. Tripolar output is typically saved on a (longitude x latitude x time) grid. Since each spatial point is located at a unique coordinate, spatial metadata is typically provided as a latitude matrix and a longitude matrix. Each matrix has size (nLon x nLat) and the coordinate for each spatial point can be obtained by querying the appropriate element in each of the latitude and longitude matrices. Let's say I have two tripolar variables, sea surface temperature and sea surface salinity, which I want to call "SST" and "SSS" respectively. The two variables extend from 1900 to 2000 with annual resolution. Then the metadata definition could be:
```matlab
file1 = 'my-tripolar-sst-data.nc';
lat = ncread(file, 'lat');
lon = ncread(file, 'lon');
coord = [lat(:), lon(:)];
time = (1900:2000)';
var = ["SST"; "SSS"];
meta = gridfile.defineMetadata('coord', coord, 'time', time, 'var', var);
```
If this N-dimensional array is (coord x time x var), then its size will be ( (nLon*nLat) spatial points x 1001 time steps x 2 variables).

<br>
**Important:** Although you can use whatever metadata format you prefer, the .grid file metadata should still describe the data in the data source files and use the same spacing. For example, say you have climate model output with 180 latitude points spaced at 1 degree resolution. Then you should define latitude metadata that has 180 points at 1 degree resolution. Similarly, if you have output that extends over 1000 years at monthly resolution, then you should define your time metadata so that it extends over those same 1000 years at monthly resolution.

<br>
## Create File

Now that the metadata is defined, we can create a new .grid file. Here the syntax is:

```matlab
gridfile.new(filename, meta);
```

where filename is the name of the .grid file. Note that gridfile adds a .grid extension if the file name does not already have one, so

```matlab
gridfile.new('myfile', meta)
```

will create a file named "myfile.grid". This file will manage data in an N-dimensional array. Since this is a new .grid file, the N-dimensional array is currently empty:

<img src="\DASH\assets\images\gridfile\grid-metadata.svg" alt="An N-dimensional array with metadata." style="width:80%;display:block">

because no data source files have been linked to the .grid file. In the next few sections of the tutorial, we will see how add data source files so that the N-dimensional array is filled with data.


<br>
### Optional: Include Non-Dimensional Attributes

You can optionally add non-dimensional metadata to a .grid file as well. For this, use the syntax
```matlab
gridfile.new('myfile', meta, attributes)
```
Here attributes is a scalar structure. It may contain anything at all you find useful. For example, you could use:
```matlab
attributes = struct('Model','CESM-LME','Units','Kelvin');
```
to remind yourself of the source of climate model output and the units of a dataset. This non-dimensional metadata will be saved to the .grid file and is accessible as .grid file metadata.

<br>

### Optional: Overwrite Existing Files
By default, gridfile.new will not overwrite an existing .grid file. However, if you wish to enable overwriting, you can set the fourth input argument to true, as per
```matlab
gridfile.new(filename, meta, attributes, true);
```

[Previous](define)---[Next](object)
