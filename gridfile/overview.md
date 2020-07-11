---
layout: simple_layout
---

# So, how does this all work?

(Don't worry, we're not going into details here. Just a quick overview to illustrate some key concepts.)

#### N-Dimensional Array
Ultimately, gridfile relies on instructions saved in a .grid file to load values from a dataset. These .grid files do not store any actual data values; instead they organize and catalogue values saved in other files. At its most basic, each .grid file manages an N-dimensional data array. This data array does not actually exist, but is an abstraction used to conceptualize how data values in different files fit together.

<img src="\assets\images\grid-empty.svg" alt="An Empty N-dimensional array." style="width:80%;display:block">
Figure 1: An N-dimensional array.

<br>

#### Unique Metadata
Each element of each dimension is associated with unique metadata. These metadata values are used to index the values in the N-dimensional grid, and can be used to load specific subsets of the full N-dimensional grid. As mentioned, gridfile is based on the concept that metadata should be meaningful to the user, so the metadata values for each dimension are specified by the user of the .grid file.

<img src="\assets\images\grid-metadata.svg" alt="An N-dimensional array with metadata." style="width:80%;display:block">
Figure 2: An N-dimensional array with metadata.

<br>

#### Data Source Files
When you create a new .grid file, the N-dimensional array is initially empty. However, you can fill the grid with values by adding data source files to the .grid file's collection. A data source file is a file that has data values saved inside it: for example, a NetCDF or Matlab .mat file. When a data source file is added to a .grid file's collection, the .grid file determines the location of the data source's values within the N-dimensional array. The .grid file also stores information such as the name of the variable in the data source file, the dimension order of that variable, any necessary unit conversion, etc. When you make a load request from a .grid file, the file determines which data source files hold the requested data. The .grid file then loads the requested data from the relevant files and pieces the loaded data together in the requested format.

<img src="\assets\images\grid-source.svg" alt="An N-dimensional array with data source files." style="width:80%;display:block">
Figure 3: Data source files located within an N-dimensional array.


[Previous](\gridfile\intro)   [Next](\gridfile\new)
