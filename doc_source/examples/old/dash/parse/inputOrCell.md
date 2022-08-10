# Parse an input that holds multiple arrays

Inputs that parse successfully:

```in
nArraysNeeded = 3;
input = {1,2,3};
[input, wasCell] = dash.parse.inputOrCell(input, nArraysNeeded)
```

```out
input = 
       {1   2   3}
       
wasCell = 
          true
```

Inputs that throw an error:

```in
nArraysNeeded = 3;
input = {1,2,3,4};
dash.parse.inputOrcell(input, nArraysNeeded)
```

```error
input must have 3 elements, but has 4 elements instead.
```

```in
nArraysNeeded = 3;
input = [1 2 3];
dash.parse.inputOrCell(input, nArraysNeeded)
```

```
input must be a cell vector, but it is a double vector instead
```

# Parse an input that holds a single array

When the array is in a cell:

```in
nArraysNeeded = 1;
input = {rand(4,4)};
[input, wasCell] = dash.parse.inputOrCell(input, nArraysNeeded)
```

```out
input =
       {4x4 double}
       
wasCell =
         true
```

When the array is provided directly:

```in
nArraysNeeded = 1;
input = rand(4,4);
[input, wasCell] = dash.parse.inputOrCell(input, nArraysNeeded)
```

```out
input =
       {4x4 double}
       
wasCell =
         false
```

The input array has been placed in a cell, and the second output notes it was not a cell originally.

# Customize error messages

Customize thrown error messages:

```in
inputName = 'my variable';
header = 'my:error:header';

input = {1};
nArraysNeeded = 3;

dash.parse.inputOrCell(input, nArraysNeeded, inputName, header);
```

```error
my variable must have 3 elements, but it has 1 element instead
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


