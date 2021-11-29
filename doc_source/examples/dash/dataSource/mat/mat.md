# Create a MAT-file dataSource

An example MAT-file:

```in
file = 'my-file.mat';
m = matfile(file);
allVariables = who(m);
variable = allVariables{1}
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
  mat with properties
    ...
```