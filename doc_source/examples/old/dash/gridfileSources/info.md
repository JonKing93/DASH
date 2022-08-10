# Information about data sources

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
                "my-file-3.nc"
        ...
```

Return an information structure:

```in
info = sources.info([2 3])
```

```out
info =
  2x1 struct array with fields:
    name
    variable
    index
    file
    data_type
    dimensions
    size
    fill_value
    valid_range
    transform
    transform_parameters
    uses_relative_path
```