# Pass test

An example gridfileSources catalogue:

```in
sources
```

```out
sources = 
  gridfileSources with properties:
    ...
    size: "4,4,5"
    type: "single"
    ...
```


A data source that passes the test:

```in
dataSource = dash.dataSource.nc('my-file.nc', 'my-variable')
```

```out
dataSource =
  nc with properties:
    ...
        size: 4  4  5  1
    dataType:  "single"
    ...
```

```in
tf = sources.ismatch(dataSource, 1)
```

```out
tf = 
    true
```

# Fail comparison

An example gridfileSources catalogue:

```in
sources
```

```out
sources = 
  gridfileSources with properties:
    ...
    size: "4,4,5"
    type: "single"
    ...
```

A data source that does not match the catalogue:

```in
dataSource = dash.dataSource.nc('example.nc', 'my-variable')
```

```out
dataSource =
  nc with properties:
    ...
        size: 6  6  2
    dataType:  "single"
    ...
```

```in
[tf, property, objValue, catalogueValue] = sources.ismatch(dataSource, 1)
```

```out
tf = 
    false
property = 
          "size"
objValue =
          6  6  2
catalogueValue = 
                4  4  5
```