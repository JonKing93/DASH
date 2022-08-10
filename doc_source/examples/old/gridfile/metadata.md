# Return gridfile metadata

Use the metadata command with no arguments to return metadata for the entire gridfile. For example:

```in
grid = gridfile('my-gridfile.grid');
metadata = grid.metadata
```

```out
metadata =
  gridMetadata with metadata:
     lat: [181x1 double]
     lon: [360x1 double]
    time: [1000x1 datetime]
```

Alternatively, use 0 as an input for the same result:

```in
grid = gridfile('my-gridfile.grid');
metadata = grid.metadata(0)
```

```out
metadata =
  gridMetadata with metadata:
     lat: [181x1 double]
     lon: [360x1 double]
    time: [1000x1 datetime]
```

# Return metadata for all data sources

Provide -1 as the input to return metadata for all data sources in the gridfile. For example:

```in
grid = gridfile('my-gridfile.grid');
nSource = numel(grid.sources)
```

```out
nSource = 
         5
```

We can see this gridfile has 5 data sources. Then, the command:

```in
sourceMetadata = grid.metadata(-1)
```

```out
sourceMetadata =
  5x1 gridMetadata array
```

returns the metadata for all 5 data sources. You can examine the elements of the metadata vector to see the metadata for each data source. For example:

```in
meta1 = sourceMetadata(1)
meta2 = sourceMetadata(2)
```

```out
meta1 =
  gridMetadata with metadata:
    time: [1000x1 datetime]
     run: 1
     
 meta2 = 
   gridMetadata with metadata:
     time: [1000x1 datetime]
      run: 2
```
 
In this example, we can see that data sources 1 and 2 hold data from two different runs.

Note that data source metadata will never include metadata attributes.
 
 
# Return metadata for specific data sources
 
You can obtain the metadata for a specific set of data sources by providing either 1. the data source names, or 2. the data source indices as input. For example:
 
```in
grid = gridfile('my-gridfile.grid');
sources = grid.dispSources
```
 
```out
1. my-source-1.mat
2. my-source-2.nc
3. my-source-3.mat
4. my-source-4.mat
5. my-source-5.nc
```

we can see that the example gridfile has 5 data sources. Get metadata for data sources 3 and 5 by either providing their names as input:

```in
sourceNames = ["my-source-3.mat", "my-source-5.nc"];
sourceMeta = grid.metadata(sourceNames)
```

```out
sourceMeta =
  2x1 gridMetadata array
```

Alternatively, provide the data source indices:

```in
sourceIndices = [3 5];
sourceMeta = grid.metadata(sourceIndices)
```

```out
sourceMeta =
  2x1 gridMetadata array
```