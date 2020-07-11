---
layout: simple_layout
title: Rename Sources
---

# Move / rename data source files

When a data source file is added to a .grid file, its absolute file path is added to the .grid file's collection. If you move the data source or rename it, then the file path in the .grid file will need to be updated.

<br>
#### Check / update all data sources

The easiest way to ensure that all data source file paths are up to date is to use:
```matlab
grid.updateSources;
```
where grid is a gridfile object. This will iterate through each data source in the .grid file and check that the file still exists. If the file no longer exists, the function will search the Matlab active path for a file with the same name (excluding path), and record that new name instead. For example, if you move "\Users\path1\myfile.nc" to "\Users\path2\subfolder\myfile.nc", the .grid file will update the full file path and name accordingly.

<br>

#### Check / update specific data sources

You can limit the .grid file to only updating a few data sources my supplying a list of data source names, as per:
```matlab
grid.renameSources( filenames )
```
where filenames is a string vector or cellstring vector of data source file names recorded in the .grid file. Note that these recorded file names will differ from the altered file names if the data source files have been moved. If an element of filenames includes a path, then only matching data sources in the .grid file will be updated. If an element of filenames does not include a path, the method will update all data sources with a matching name.

<br>

#### Specify the renamed files.

If you renamed a data source (for example, from "myfile.nc" to "different-name.nc"), or if you moved data source files off the Matlab active path, then you will need to specify the new name of the files. Do so via:
```matlab
grid.renameSources( filenames, newnames )
```
where newnames is a string vector or cellstring vector containing the updated file names. Each element of newnames must be for the corresponding element in filenames. If an element of newnames includes a file path, then the new file path is used directly. If an element of new names does not include a file path, then the method searches the Matlab active path for a file with the matching name and records its path.
