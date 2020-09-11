---
layout: simple_layout
title: "New .grid File"
---

# Create a new .grid file

### Define Metadata

We'll start by defining the metadata for the .grid file. This metadata specifies the metadata for each dimension in the .grid file, and is used to organize the N-dimensional array. To define metadata, use:

```matlab
meta = gridfile.defineMetadata(dimension1, metadata1, dimension2, metadata2, ..., dimensionN, metadataN);
```

Here, the syntax is to provide the name of a dimension and then its metadata, then repeat for all dimensions in the dataset. Hence, dimension1, dimension2, ..., dimensionN are a set of dimension names. By default, gridfile allows the following dimension names:
* <span style="color:#cc00cc">"lon"</span> -- for the longitude / x dimension
* <span style="color:#cc00cc">"lat"</span> -- for the latitude / y dimension
* <span style="color:#cc00cc">"coord"</span> -- for non-regular spatial grids
* <span style="color:#cc00cc">"lev"</span> -- the level / height / z dimension
* <span style="color:#cc00cc">"time"</span> -- the time dimension
* <span style="color:#cc00cc">"run"</span> -- for individual members of an ensemble
* <span style="color:#cc00cc">"var"</span> -- for different variables on the same spatial/temporal grid

You DO NOT need to provide metadata for all these dimensions; only the dimensions appearing in your dataset need metadata. Also, you may provide the dimensions in any order, regardless of the dimension order of your dataset. (If you would like to use different dimension names, you can [rename dimensions](change-dimension-names). If your dataset has more dimensions that the 7 defaults, you can [add new dimensions](add-dimension-names)).

Next, metadata1, metadata2, ..., metadataN are the metadata fields along each specified dimension. Each row of a metadata field is used to index one element along a dimension, so each row must be unique. Metadata can use numeric, logical, string, char, cellstring, or datetime formats, but cannot contain NaN or NaT elements. In general, it's best to use metadata values that are meaningful to you, as this will allow you to reuse the .grid file many times in the future. You DO NOT need to use metadata values found in data source files.

The following is an example of a typical metadata definition.

```matlab
lat = (-90:90)';
lon = (0:360)';
time = (850:2005)';
meta = gridfile.defineMetadata("lat", lat, "lon", lon, "time", time);
```

<br>

### Create File

Now that the metadata is defined, we can create a new .grid file. Here the syntax is:

```matlab
gridfile.new(filename, meta);
```

where filename is the name of the .grid file. Note that gridfile adds a .grid extension if the file name does not already have one, so

```matlab
gridfile.new('myfile', meta)
```

will create a file named "myfile.grid".

<br>

### Optional: Include Non-Dimensional Metadata

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

[Previous](overview)---[Next](object)
