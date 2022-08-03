# Parse indices

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
                "path/to/file-3.nc"
        ...
```

Get linear indices to data sources:

```in
logicalIndices = [false, true, true];
indices = sources.indices(logicalIndices)
```

```out
indices = 
         2  3
```


# Parse names

An example gridfileSources catalogue:

```in
sources
```

```out
sources =
  gridfileSources with properties:
        ...
        sources: 
                "path/to/my-file-1.mat"
                "my-file-2.nc"
                "path/to/my-file-3.nc"
        ...
```

Get indices to named sources:

```in
names = ["my-file-3.nc", "to/my-file-1.mat"];
indices = sources.indices(names)
```

```out
indices = 
         3  1
```

# Invalid indices

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
                "path/to/file-3.nc"
        ...
```

Invalid indices:

```in
logicalIndices = true(15,1);
indices = sources.indices(logicalIndices)
```

```error
input is a logical vector, so it must have one element per data source (3), but it has 15 elements instead
```


# Invalid names

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
                "path/to/file-3.nc"
        ...
```

Invalid names:

```in
names = "not-a-file.nc"
indices = sources.indices(names)
```

```error
No data sources match input data source 1 ("not-a-file.nc")
```


# Customize Error

Use a custom error ID:

```in
header = "my:error:header"
try
    indices = sources.indices("not-a-source", header)
catch ME
end
identifier = ME.identifier
```

```out
identifier =
            "my:error:header"
```