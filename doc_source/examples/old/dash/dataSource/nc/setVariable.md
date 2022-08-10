# Record NetCDF variable name

An example dataSource object without a variable name:

```in
dataSource
```

```out
dataSource =
  nc with properties
    ...
        var: 0x1 empty string array
    ...
```

Save a variable name:

```in
info = ncinfo(dataSource.source);
variable = info.Variables(1).Name;
allVariables = {info.Variables.Name};

dataSource = dataSource.setVariable(variable, allVariables)
```

```out
dataSource =
  nc with properties
    ...
        var: "exampleName"
    ...
```