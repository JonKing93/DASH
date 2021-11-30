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


# Customize error message

Use the first input to provide a custom error ID. For example, create a metadata object with repeated metadata rows

```in
site = [30 50
        20 10
        30 50
        40 40];
meta = gridMetadata('site', site);

header = "my:header";
meta.assertUnique
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
    'my:header'
```