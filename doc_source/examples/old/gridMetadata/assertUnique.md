# Assert metadata rows are unique

An example that passes the assertion:

```
site = [1 1 2;
        1 2 2;
        3 3 3];
time = (datetime(0,1,1):calyears(1):datetime(2000,1,1))';
run = ["Full forcing";"Control"];
meta = gridMetadata('site', site, 'time', time, 'run', run);

meta.assertUnique
```

The object passes the assertion because all metadata rows are unique.

An example that fails the assertion:

```in
site = [30 50
        20 10
        30 50
        40 40];
time = (datetime(0,1,1):calyears(1):datetime(2000,1,1))';
run = ["Full forcing";"Control"];
meta = gridMetadata('site', site, 'time', time, 'run', run);

meta.assertUnique
```

```error
The "site" metadata has duplicate rows. (Rows 1 and 3)
```

The object fails the assertion because the metadata for the "site" dimension has repeated rows.

Note that metadata rows must only be unique within each individual dimension. Different dimensions can have rows with the same metadata values. For example:

```
lat = (-90:90)';
lon = (1:360)';
meta = gridMetadata('lat', lat, 'lon', lon)
```

both the "lat" and "lon" dimensions in this metadata have rows with the values from 1 to 90. However, these values are unique within each dimension, so the metadata object still passes the assertion:

```
meta.assertUnique
```


# Check specific dimensions

If you provide dimension names as the first input, the method only checks the metadata for the specified dimensions. For example:

```in
meta = gridMetadata('site', [1;1;2;2;3], 'time', (1900:2000)', 'run', (1:5)')
```

```out
meta = 
  gridMetadata with metadata:
    site: [5×1 double]
    time: [101×1 double]
     run: [5×1 double]
```

In this example, the "site" dimension has repeated metadata rows, but the "time" and "run" dimensions do not. If we call the method on the "time" and "run" dimensions, the assertion still passes. For example:

```
dimensions = ["time","run"];
meta.assertUnique(dimensions);
```

The assertion passes and does not throw an error. By contrast, if we include the "site" dimension in the dimensions list:

```in
dimensions = ["site","time"];
meta.assertUnique(dimensions)
```

```error
The "site" metadata has duplicate rows. (Rows 1 and 2)
```


# Customize error message

Use the first input to provide a custom error ID. For example, create a metadata object with repeated metadata rows

```in
site = [30 50
        20 10
        30 50
        40 40];
meta = gridMetadata('site', site);

header = "my:header";
meta.assertUnique([], header)
```

```error
The "site" metadata has duplicate rows. (Rows 1 and 3)
```

Examine the error ID:

```in
ME = lasterror;
ID = ME.identifier
```

```out
ID = 
    'my:header:duplicateRows'
```