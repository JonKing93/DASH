# Record HDF variable name

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

Example variables in an HDF file:

```in
allVariables
variable
```

```
allVariables =
              "var1"  "var2" "exampleVar"
variable =
          "exampleVar"
```

Record the variable name:

```in
dataSource = dataSource.setVariable(variable, allVariables)
```

```out
dataSource =
  mat with properties
    ...
        var: "exampleVar"
    ...
```