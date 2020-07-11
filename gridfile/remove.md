---
layout: simple_layout
---
# Remove data source files from a .grid file.

If you accidentally add a data source file to a .grid file, you may wish to remove it. The syntax is
```matlab
grid.remove(filename)
```
where
* grid is a gridfile object, and
* filename is the name of the data source file.

If you use a full file name, for example:
```matlab
filename =  "\Users\filepath\myfile.nc"
```
then only files matching the full file path will be removed. If you do not know the full path of the data, you can use just the filename
```matlab
filename = "myfile.nc"
```
and the method will remove any data source files matching the given name from the .grid file.

<br>

#### Include a variable name

You can exercise greater control over the "remove" method by also specifying the name of a variable. For example:
```matlab
grid.remove( filename, variable )
```
In this case, only data sources that match both the file and variable name will be removed from the .grid file.
