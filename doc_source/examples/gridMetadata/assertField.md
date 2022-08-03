# Check metadata is valid

The method checks that metadata:

1. Is a matrix
2. Is numeric, logical, char, string, cellstring, or datetime
3. Does not have NaN or NaT elements

An example that passes the assertion:

```
meta = rand(4,5);
gridMetadata.assertField(meta)
```

Values that are not matrices will cause an error:

```in
meta = rand(4,5,6);
gridMetadata.assertField(meta)
```

```error
The metadata is not a matrix
```

Unsupported data types will also cause an error.

```in
meta = {1,2,3};
gridMetadata.assertField(meta)
```

```error
The metadata must be one of the following data types: 
"numeric", "logical", "char", "string", "cellstring", and "datetime"
```

Metadata with NaN or NaT elements will also cause an error:

```in
meta = [1;2;NaN;4;5];
gridMetadata.assertField(meta)
```

```error
The metadata contains NaN elements.
```

```in
meta = [datetime(1,1,1); datetime(2,1,1); NaT];
gridMetadata.assertField(meta)
```

```error
The metadata contains NaT elements.
```

# Convert cellstring to string

If the input passes the assertion, it is returned as output. If the input was a cellstring matrix, it is returned as a string matrix. This ensures that returned metadata can be indexed using parentheses, rather than braces:

```in
meta = { 'a',  'cellstring'
         'metadata',  'matrix'};
meta = gridMetadata.assertField(meta)
```

```out
meta = 
  2×2 string array
    "a"           "cellstring"
    "metadata"    "matrix"   
```


# Customize error message

Customize the error message to include the name of the dimension and a custom error ID:

```in
dimension = "lat";
header = "my:header";

meta = rand(4,4,4);
gridMetadata.assertField(meta, dimension, header)
```

```error
The "lat" metadata is not a matrix
```

Also examine the error ID:

```in
ME = lasterror;
ID = ME.identifier
```

```out
ID =
    'my:header:metadataNotMatrix'
```