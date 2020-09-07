---
layout: simple_layout
title: "Summarize .grid File"
---

# Get a summary of a .grid file's contents

#### Summarize file in console
If you forget the contents of a .grid file, you can print a summary of its contents to the Matlab console using:
```matlab
grid.info;
```
where grid is a gridfile object. The summary will include information on the .grid file's dimensions, the size of the N-dimensional array, number of data sources, and dimensional metadata.

<br>

#### Summarize data sources
You can include information about specific data sources in the .grid file in the summary, by doing:
```matlab
grid.info( filename );
```
where filenames is a list of data source file names. The summary for each data source will include the variable name, its dimensions, its size, and its dimensional metadata. Alternatively, you can use
```matlab
grid.info( s );
```
to obtain a summary of data sources. Here, s is a set of indices that refer to specified data sources. The index for a data source is the order in which it was added to the .grid file. To include a summary of all data sources in the .grid file, you can use
```matlab
grid.info('all');
```
<br>
#### Return summary as a structure
You can also return the .grid file and data source summaries as a structure. Specifying output arguments:
```matlab
[gridInfo, sourceInfo] = grid.info( 'all' );
```
will cause the method to return these structures and not print anything to the console.
