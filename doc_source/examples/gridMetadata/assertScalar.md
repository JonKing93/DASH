# Assert gridMetadata is scalar

Examples that pass the assertion:

```in
meta1 = gridMetadata
meta2 = gridMetadata('lat',(-90:90)', 'lon', (0:360)')
```

```out
meta1 = 
  gridMetadata with no metadata.

meta2 =   
  gridMetadata with metadata:
    lon: [361×1 double]
    lat: [181×1 double]
```

```
meta1.assertScalar
meta2.assertScalar
```

Both metadata objects pass the assertion.

An example that fails the assertion:

```in
meta1 = gridMetadata('lat',(-90:90)');
meta2 = gridMetadata('lon', (1:360)');

meta = [meta1, meta2]
```

```out
meta =
  1x2 gridMetadata array
```

```
meta.assertScalar
```

```error
Variable "meta" is not a scalar gridMetadata object. 
Instead "meta" is a gridMetadata array.
```


# Customize error message

You can also provide a custom error ID using the first input. For example:

```in
meta1 = gridMetadata('lat',(-90:90)');
meta2 = gridMetadata('lon', (1:360)');
meta = [meta1, meta2];

header = "my:header";
meta.assertScalar(header)
```

```error
Variable "meta" is not a scalar gridMetadata object. 
Instead "meta" is a gridMetadata array.
```

Examine the error ID:

```in
ME = lasterror;
ID = ME.identifier
```

```out
ID = 
    'my:header:objectArrayNotSupported''
```

