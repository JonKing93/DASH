# Linear indices

Linear indices must be positive scalar integers that do not exceed the length of the indexed array dimension. They can contain repeated elements. An examples that passes the assertion:

```in
dimensionLength = 5;
indices = [2 5 4 3 3];
indices = dash.assert.indices(indices, dimensionLength);
```

```out
indices =
         [2 5 4 3 3]
````

Examples that fail the assertion:

Values less than 1:

```in
indices = [1 2 0 3];
dash.assert.indices(indices, 5)
```

```error
Element 3 is not a positive integer
```

Non-integer values:

```in
indices = [1 2 2.2 3]
dash.assert.indices(indices, 5)
```

```error
Element 3 is not a positive integer
```

Values greater than the dimension length:

```in
dimensionLength = 5;
indices = [1 2 5 6]

dash.assert.indices(indices, dimensionLength)
```

```error
Element 4 is greater than the length of the dimension
```

# Logical indices

Logical indices must be the a vector the length of the dimension. If valid, they are returned as linear indices in the function output. An example that passes the assertion:

```in
dimensionLength = 5;
indices = [true true false false true];

indices = dash.assert.indices(indices, dimensionLength)
```

```out
indices =
         [1 2 5]
```


An example that fails the assertion:

```in
dimensionLength = 5;
indices = [true false];

indices = dash.assert.indices(indices, dimensionLength)
```

```error
input must have 5 elements, but it has 2 elements instead
```

# Customize error message

Customize the error message to enhance information about input requirements:

```in
% Set some phrases for use in error messages.
inputName = 'my variable';
logicalLengthName = 'one element per XYZ';
linearMaxName = 'the number of Ps in Q';
header = 'my:error:header';
```

Failed logical indices:

```in
dimensionLength = 5;
indices = [true false];
dash.assert.indices(indices, dimensionLength, inputName, ...
    logicalLengthName, linearMaxName, header);
```

```error
my variable is a logical vector, so it must have one element per XYZ (5), but it has 2 elements instead
```

Failed linear indices:

```in
dimensionLength = 5;
indices = [1 2 7]'
dash.assert.indices(indices, dimensionLength, inputName, ...
    logicalLengthName, linearMaxName, header);
```

```error
Element 3 of my variable is greater than the number of Ps in Q (5)
```

Also examine the error ID:

```in
ME = lasterror;
ID = ME.identifier
```

```out
ID =
    'my:error:header'
```
