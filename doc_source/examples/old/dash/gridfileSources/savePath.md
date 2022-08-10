# Path to new data source

An example gridfileSources catalogue:

```in
sources
```

```out
sources =
  gridfileSources with properties:
  
    gridfile: "my-file"
        sources: 
                "my-file-1.mat"
                "my-file-2.mat"
        ...
```

Get the new data source and whether to attempt to use a relative path:

```
tryRelative = true;
dataSource = dash.dataSource.nc('another-file.nc', 'my-variable');
```

Record the path to the new data source

```in
sources = sources.savePath(dataSource, dataSource)
```

```out
sources =
  gridfileSources with properties:
  
    gridfile: "my-file"
        sources: 
                "my-file-1.mat"
                "my-file-2.mat"
                "another-file.nc"
        ...
```

# Update path to data source

An example gridfileSources catalogue:

```in
sources
```

```out
sources =
  gridfileSources with properties:
  
    gridfile: "my-file"
        sources: 
                "path/to/file-1.mat"
                "path/to/my-file-2.mat"
        ...
```  

Get the new path, whether to attempt a relative path, and the index of the data source

```
newLocation = "different/path/to/file.mat"
tryRelative = false;
s = 2;
```

Update the path

```in
sources = sources.savePath(newLocation, tryRelative, s)
```

```out
sources =
  gridfileSources with properties:
  
    gridfile: "my-file"
        sources: 
                "path/to/file-1.mat"
                "different/path/to/file.mat"
        ...
```  

