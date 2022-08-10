# Assert input is data type

Examples that pass the assertion:
```
dash.assert.type(5, 'numeric')
dash.assert.type(5, 'double')
dash.assert.type(false, 'logical')
dash.assert.type(struct('myField',1), 'struct')
dash.assert.type("a string", 'string')
dash.assert.type({rand(4,5)}, 'cell')
```

Examples that fail the assertion:
```in
dash.assert.type({5}, 'numeric')
```

```error
input must be a numeric data type, but it is a cell data type instead
```

```in
dash.assert.type("a string", 'char')
```

```error
input must be a char data type, but it is a string data type instead
```


# Customize the error message

Customize the error messages so they appear to originate from a calling function:

```in
name = "my variable";
description = "(data type descriptor)";
idHeader = "my:error:header";

dash.assert.type({5}, 'logical')
```

```error
my variable must be a logical (data type descriptor), but it is a cell (data type descriptor) instead
```

Also examine the error ID:

```in
ME = lasterror;
ID = ME.identifier
```

```out
ID =
    'my:error:header:inputWrongType'
```