# Assert input is strlist

Example inputs that pass the assertion:

```
dash.assert.strlist(["A","string","vector"])
dash.assert.strlist({'A','cellstring','vector'})
dash.assert.strlist('A char row vector')
```

Example inputs that fail the assertion:

```in
dash.assert.strlist(5)
dash.assert.strlist(true)
dash.assert.strlist(["An", "example"; "string", "matrix"])
```

```error
input must be a string vector, cellstring vector, or character row vector
```

# Customize Error

Customize the error message so it mimics errors from a calling function:

```in
name = 'my variable';
header = 'myHeader';
dash.assert.strflag(5, name, header);
```

```error
my variable must be a string vector, cellstring vector, or character row vector
```

Examine the error ID:

```in
ME = lasterror;
ID = ME.identifier
```

```out
ID =
    myHeader:inputNotStrlist
```

# Convert input to string

If the assertion passes, the input is returned as a string vector. Use this to allow for a single data type (string) in subsequent code. For example:

```in
input = {'A', 'cellstring', 'vector'};
str = dash.assert.strflag(input);
type = class(str)
```

```out
type =
      'string'
```

The cellstring input has been converted to a string data type.
