# Record MAT-file variable name

An example dataSource object without a variable name:

```in
dataSource
```

```out
dataSource =
  mat with properties
    ...
        var: 0x1 empty string array
    ...
```

Save a variable name:

```in
allVariables = who(dataSource.m);
variable = allVariables{1};

dataSource = dataSource.setVariable(variable, allVariables)
```

```out
dataSource =
  mat with properties
    ...
        var: "exampleName"
    ...
```