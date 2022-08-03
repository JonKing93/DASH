# Build dataSource object from catalogued path

An example gridfileSources catalogue:

```in
sources
```

```out
sources =
  gridfileSources with properties:
        ...
        sources: 
                "my-file-1.mat"
                "my-file-2.nc"
        ...
```

Build the data source object for the second data source

```in
s = 2;
dataSource = sources.build(s)
```

```out
dataSource = 
  nc with properties:
    source: "my-file-2.nc"
    ...
```

# Build dataSource object from custom path

An example gridfileSources catalogue:

```in
sources
```

```out
sources =
  gridfileSources with properties:
        ...
        sources: 
                "my-file-1.mat"
                "my-file-2.nc"
        ...
```

Build a dataSource object for the second source, but use a custom path:

```in
s = 2;
customPath = "a-different-file.nc";

dataSource = sources.build(s, customPath)
```

```out
dataSource = 
  nc with properites:
    source: "a-different-file.nc"
    ...
```
