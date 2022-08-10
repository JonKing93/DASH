# Print metadata attributes to console

Create an example gridMetadata object:

```
attributes = struct('Units', 'Kelvin', 'pressure', 1000);
meta = gridMetadata('attributes', attributes);
```

Print the attributes to the console:

```in
meta.dispAttributes
```

```out
       Units: 'Kelvin'
    pressure: 1000
```