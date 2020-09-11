---
layout: simple_layout
title: Gridfile Quickstart
---

# Welcome to the gridfile quickstart!

This provides a brief overview of gridfile workflow. If you're looking for something a bit more in depth, check out the step by step [tutorial](welcome).

If you'd like to use the quickstart offline or from the Matlab console, you can download it
<a href="quickstart.m" download>here</a> or from the [tutorials branch](https://github.com/JonKing93/DASH/tree/Tutorials) on Github.

#### Define metadata for a .grid file.
```matlab
meta = gridfile.defineMetadata(dimension1, metadata1, dimension2, metadata2, ..., dimensionN, metadataN);
```
<br>
#### Create a new .grid file
```matlab
grid = gridfile.new('myfile.grid', meta);
```
<br>
#### Add data sources to the .grid file
```matlab
for s = 1:nSources
	sourceMeta = gridfile.defineMetadata( sourceDim1, sourceMetadata1(s), sourceDim2, sourceMetadata2(s), ..., sourceDimN, sourceMetadataN(s) );
	dimensionOrder = [dim1, dim2, ..., dimN]
	grid.add( filename(s), variableName(s), dimensionOrder, sourceMeta );
end
```
<br>
#### Load a subset of the data organized by the .grid file
```matlab
metadata = gridfile.metadata( 'myfile.grid' );
subset1 = metadata.dimension1 >= value1;
subset2 = metadata.dimension2 <= value2;

[X, Xmeta] = grid.load( [dimension1, dimension2], {subset1, subset2} );
```
