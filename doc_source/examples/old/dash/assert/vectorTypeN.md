# Assert input is a vector with required data type and length

Examples that pass the assertion:

```
dash.assert.vectorTypeN([1 2 3], 'numeric', 3)
dash.assert.vectorTypeN([1 2 3], 'double', 3)
dash.assert.vectorTypeN(true(4,1), 'logical', 4)
dash.assert.vectorTypeN(["a","string","vector"], 'string', 3)
```

Examples that fail the assertion

```in
dash.assert.vectorTypeN(rand(4,4), 'numeric', 16)
```

```error
input is not a vector
```

```in
dash.assert.vectorTypeN(true(4,1), 'numeric', 5)
```

```error
input must be a numeric vector, but it is a logical vector instead
```

```in
dash.assert.vectorTypeN([1 2 3], 'numeric', 4)
```

```error
input must have 4 elements, but has 3 elements instead
```


# Ignore data type

Use an empty array for the second input to not require a data type:

```
dash.assert.vectorTypeN([1 2 3], [], 3)
```

# Ignore vector length

Use an empty array for the third input to not require a vector length:

```
dash.assert.vectorTypeN([1 2 3], 'numeric', [])
```

# Customize error message

Customize the error message so it appears to originate from a calling function:

```in
name = "my variable";
idHeader = "my:error:header";

dash.assert.vectorTypeN(rand(4,4), 'numeric', 16)
```

```error
my variable is not a vector
```

Also examine the error ID:

```in
ME = lasterror;
ID = ME.identifier
```

```out
ID =
    'my:error:header:inputNotVector'
```



