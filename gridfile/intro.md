---
layout: simple_layout
title: Introduction
---

# So, why use gridfile?

In many scientific fields, it's common to use multiple geospatial datasets to perform an analysis. For example, I may want to compare temperature data from:
1. A climate model simulation,
2. An instrumental record, and
3. A laboratory reconstruction.

However, different datasets use a variety of different conventions to record their data. For example, datasets may save data in different file formats, use different names for the same variables, record variables in different dimensional orders, use different units, and use different metadata formats. Furthermore, both data and metadata are often provided in units or formats that are not directly meaningful for users. Consequently, using multiple datasets often necessitates: learning multiple data conventions, loading data from different files, rearranging loaded data to fit a desired format, converting data to common units, and changing metadata to a more meaningful format. This process is typically both tedious and time-consuming, and gridfile provides a possible solution.

In brief, gridfile allows values stored in different datasets to be accessed via a single set of common commands. Gridfile is based on the idea that data and metadata should be meaningful to the user, so all data is organized via the user's preferred metadata format. Furthermore, gridfile can automatically convert data values to the same units, load values in any requested dimensional format, and efficiently access subsets of large datasets. If any of these features sound useful, then this tutorial is for you.

# A quick example

To illustrate how gridfile can facilitate file I/O, consider the following scenario: Let's say I want to analyze temperature data from three datasets.

#### Dataset 1
Temperature values from a climate model simulation. These temperatures are saved in NetCDF files under the name "tas" with a dimensional order of (longitude x latitude x time). The values are split across two files; the first records temperatures from 850 CE to 1849 CE, and the second records temperatures from 1850 CE to 2005 CE. The time metadata is provided as days since 850 CE, and the temperature values are in units of Kelvin. The dataset has a resolution of 2.5 degrees longitude by 4 degrees latitude and uses a [0, 360] longitude coordinate system.

#### Dataset 2
Temperature values from an instrumental reanalysis. The temperatures are saved in a NetCDF file under the name "TREFHT" with a dimensional order of (latitude x longitude x time). Time metadata is provided as decimal years, and temperature values are in Celsius. The dataset has a resolution of 1 degree longitude by 1 degree latitude and uses a [-180, 180] longitude coordinate system.

#### Dataset 3
A laboratory temperature reconstruction. The temperatures are saved in a Matlab .mat file under the name "T" with a dimensional order of (time x latitude x longitude). Time metadata is provided as a date vector, and temperature values are in Celsius. The dataset has a resolution of 5 degrees longitude by 5 degrees latitude and uses a [0, 360] longitude coordinate system.

These datasets use many different conventions, and preparing the data for analysis will take quite a bit of effort. However, we can use gridfile to simplify this process. Without getting into details (that's the rest of the tutorial!), we can use gridfile to organize and catalogue the values in each dataset. The details for each dataset are saved in a file ending in a .grid extension. For this example, let's say we named the .grid files:
1. T-Model.grid
2. T-Instrumental.grid, and
3. T-Lab.grid

Then the following 5 lines of code:

```matlab
metadata = gridfile.metadata( gridname );
NH = metadata.lat > 0;
post1800 = metadata.time > 1800;

grid = gridfile( gridname );
[T, Tmetadata] = grid.load( ["time", "lat"], {post1800, NH});
```

will allow us to load Northern Hemisphere temperature values post 1800 CE from ANY of the three datasets. We'll also receive metadata for the loaded values. Furthermore, the loaded values and metadata will have:
1. The same dimension order -- whatever order is requested, here I used time x latitude x longitude.
2. The same units -- whatever units I prefer, let's say Celsius.
3. The same longitude coordinate system -- again, whichever format I prefer, we'll say I prefer [0 360].
4. The same time metadata format -- we'll say I prefer decimal years.

Pretty convenient!


[Previous](\DASH\gridfile\welcome)    [Next](\DASH\gridfile\overview)
