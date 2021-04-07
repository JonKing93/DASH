---
sections:
  - Define metadata
  - Dimension names
  - Dimension metadata
---

# Custom Metadata

One powerful feature of gridfile is the ability to organize a dataset using custom metadata. Climate data is often provided with metadata, such as spatial coordinates and time steps. However, you may find that the format of this metadata is not always useful and instead convert the metadata to some other format.

For example, many climate models provide time metadata as "Days since X", where X is a particular date. I do not find this a useful format and inevitably convert the time metadata to a datetime (or date vector or decimal year) format. By using gridfile, I can define the time metadata for a dataset using my preferred format and then use that preferred format to manipulate and subset the data for data assimilation.

For a second example, note that variable names are a form of metadata. Climate data from different sources may refer to the same climate variables by different names. For example, CMIP5 output refers to surface temperature using the "tas" moniker. By contrast, surface temperature is named "TREFHT" in output from CESM. Different naming schemes can complicate multi-model analyses, but such analyses are useful for paleoclimate data assimilation. By using gridfile, you can define metadata for variables using a preferred name. For example, I could define metadata for CMIP5 and CESM datasets so that surface temperature could be accessed using the name "Temperature".

### Define metadata

To define metadata for a dataset, we will use the "defineMetadata" command. This is a general method that builds a metadata structure that describes the scope of a data set. We will use this command at two different points in the tutorial. First to describe the scope of a .grid file's N-dimensional array,

<img src="\DASH\assets\images\gridfile\grid-metadata.svg" alt="An N-dimensional array with metadata." style="width:80%;display:block">

 and later to define the scope of the data saved in each data source file.

 <img src="\DASH\assets\images\gridfile\grid-source.svg" alt="An N-dimensional array with data source files." style="width:80%;display:block">

The syntax for using the defineMetadata method is:
```matlab
meta = gridfile.defineMetadata(dimension1, metadata1, dimension2, metadata2, ..., dimensionN, metadataN);
```

Here, the style is to provide the name of a dimension and then its metadata; this pattern is repeated for all dimensions in the dataset. Hence, Hence, dimension1, dimension2, ..., dimensionN are a set of dimension names.

#### Dimension Names
By default, gridfile allows the following dimension names:

* <span style="color:#cc00cc">"lon"</span> -- for the longitude / x dimension
* <span style="color:#cc00cc">"lat"</span> -- for the latitude / y dimension
* <span style="color:#cc00cc">"coord"</span> -- for non-regular spatial coordinates
* <span style="color:#cc00cc">"lev"</span> -- the level / height / z dimension
* <span style="color:#cc00cc">"time"</span> -- the time dimension
* <span style="color:#cc00cc">"run"</span> -- for individual members of an ensemble
* <span style="color:#cc00cc">"var"</span> -- for different variables on the same spatial/temporal grid

"lat" and "lon" are used to define latitude and longitude coordinates for a regular, gridded dataset. The "coord" dimension is used to define unique spatial coordinates for a dataset. This is useful for data that does not conform to a [regular latitude-longitude grid](https://en.wikipedia.org/wiki/Regular_grid). For example, data at irregular spatial points (like that from field sites or weather stations), and data on a non-regular grid (like tripolar climate model output). The "lev" dimension is used to define height metadata, and "time" is used to define metadata for time steps. The "run" dimension is useful for providing metadata about different members of an ensemble. This can be useful for climate models that run multiple simulations of the same time period and for certain types of Monte Carlo analyses. The "var" dimension can be used to define metadata for the variables in a dataset. This can be used to provide a custom name for variables in a dataset. If a dataset includes multiple climate variables, this can also be used to distinguish between them.

You DO NOT need to provide metadata for all these dimensions; only the dimensions appearing in your dataset need metadata. Also, you may provide the dimensions in any order, regardless of the dimension order of your dataset. (If you would like to use different dimension names, you can [rename dimensions](change-dimension-names). If your dataset has more dimensions that the 7 defaults, you can [add new dimensions](add-dimension-names)).

#### Dimension metadata

Returning to the "defineMetadata" syntax:
```matlab
meta = gridfile.defineMetadata(dimension1, metadata1, dimension2, metadata2, ..., dimensionN, metadataN);
```

metadata1, metadata2, ..., metadataN are the metadata fields along each specified dimension. Each row of a metadata field is used to index one element along a dimension, so each row must be unique. Metadata can use numeric, logical, string, char, cellstring, or datetime formats, but cannot contain NaN or NaT elements. In general, it's best to use metadata values that are meaningful to you, as this will allow you to reuse the .grid file many times in the future.

If this feels a bit abstract, don't worry. In the next section, we'll see some concrete examples of how this all works and use it to help create a new .grid file.
