# Return all absolute paths

An example gridfileSources object:

```in
sources
```

```out
sources =
  gridfileSources with properties:
    gridfile: "my-path/my-grid"
    ...
    source:
         "./file.mat"
         "https://my-opendap.nc"
         "./a/relative/../path/file.mat"
    relativePath:
         true
         false
         true
    ...
```

Return the absolute paths:

```in
paths = sources.absolutePaths
```

```out
paths = 
       "my-path/file.mat"
       "https://my-opendap.nc"
       "my-path/a/path/file.mat"
```

# Return specific paths

An example gridfileSources object:

```in
sources
```

```out
sources =
  gridfileSources with properties:
    gridfile: "my-path/my-grid"
    ...
    source:
         "./file.mat"
         "https://my-opendap.nc"
         "./a/relative/../path/file.mat"
    relativePath:
         true
         false
         true
    ...
```

Return requested paths:

```in
paths = sources.absolutePaths([3 1])
```

```out
paths = 
       "my-path/a/path/file.mat"
       "my-path/file.mat"
```