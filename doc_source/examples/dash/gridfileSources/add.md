# Add data source to catalogue

Get the associated gridfile:

```
grid = gridfile('my-grid.grid');
```

Also get the new data source:

```
dataSource = dash.dataSource.nc('my-nc-file.nc', 'my-variable');
```

Get merged/unmerged dimension information:

```
dims = ["lat","lon","time"];
size = [181, 360, 1000];
mergedDims = ["site","time"];
mergedSize = [181*360, 1000];
mergeMap = [1 1 2];
```

Add to catalogue:

```
sources = dash.gridfileSources;
sources = sources.add(grid, dataSource, dims, size, mergedDims, mergedSize, mergeMap)
```
