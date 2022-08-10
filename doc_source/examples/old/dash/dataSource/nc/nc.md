# Create a NetCDF dataSource

An example NetCDF file:

```in
file = 'my-netcdf.nc';
info = ncinfo(file);
variable = info.Variables(1).Name
```

```out
variable = 
          'exampleName'
```

Create a dataSource:

```in
dataSource = dash.dataSource.nc(file, variable)
```

```out
dataSource =
  nc with properties
    ...
```

# Create dataSource for an OPENDAP NetCDF

An example OPENDAP NetCDF:

```in
file = 'https://an/opendap/file.nc';
info = ncinfo(file);
variable = inf.Variables(1).Name
```

```out
variable = 
          'exampleName'
```

Create a dataSource:

```in
dataSource = dash.dataSource.nc(file, variable)
```

```out
dataSource =
  nc with properties
    ...
```