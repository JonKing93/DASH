# Assert input is strflag

Example inputs that pass the assertion:

```in
dash.assert.strflag("A string scalar")
dash.assert.strflag('A char row vector')
```

Example inputs that fail the assertion:

```in
dash.assert.strflag(5)
dash.assert.strflag(true)
dash.assert.strflag({'A cellstring scalar'})
dash.assert.strflag(["A","string","vector"])
```

```error
input must be a string scalar or character row vector
```

# Customize Error

Customize the error message so it mimics errors from a calling function:

```in
name = 'my variable';
header = 'myHeader';
dash.assert.strflag(5, name, header);
```

```error
my variable must be a string scalar or character row vector
```

Examine the error ID:

```in
ME = lasterror;
ID = ME.identifier
```

```out
ID =
    myHeader:inputNotStrflag
```

# Convert input to string

If the assertion passes, the input is returned as a scalar string. Use this to allow for a single data type (string) in subsequent code. For example:

```in
input = 'A char row vector';
str = dash.assert.strflag(input);
type = class(str)
```

```out
type =
      'string'
```

The char input has been converted to a string data type.
