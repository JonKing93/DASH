# Assert input is scalar and required data type

Examples that pass the assertion:

```
dash.assert.scalarType(5, 'numeric')
dash.assert.scalarType(5, 'float')
dash.assert.scalarType(false, 'logical')
dash.assert.scalarType( {rand(4,5)}, 'cell')
```

Examples that fail the assertion because they are not scalar

```in
dash.assert.scalarType([5,6,7], 'numeric')
dash.assert.scalarType(true(5,1), 'logical')
```

```error
input is not scalar
```

Examples that fail because they are the wrong type:

```in
dash.assert.scalarType({5}, 'numeric')
```

```error
input must be a numeric scalar, but it is a cell scalar instead
```

```in
dash.assert.scalarType({true}, 'logical')
```

```
input must be a logical scalar, but it is a cell scalar instead
```


# Only assert scalar (ignore data type)

Use an empty array as the second input to only assert the input is scalar:

```
dash.assert.scalarType(5, [])
dash.assert.scalarType(true, [])
dash.assert.scalarType("a string", [])
```


# Customize Error

Customize the error message to it appears to originate from a calling function:

```in
inputName = "my variable";
idHeader = "my:error:header"

dash.assert.scalarType([1 2 3], 'numeric', inputName, idHeader)
```

```error
my variable is not scalar
```

Also examine the error ID:

```in
ME = lasterror;
ID = ME.identifier
```

```out
ID =
    'my:error:header:inputNotScalar'
```