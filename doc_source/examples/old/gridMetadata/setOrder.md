# Set a dimension order

Create an example gridMetadata object:

```in
lat = (-90:90)';
lon = (1:360)';
time = (datetime(1,1,1):calmonths(1):datetime(2000,12,1))';
run = ["Control";"Full-forcing"];

meta = gridMetadata('lat', lat, 'lon', lon, 'time', time, 'run', run)
```

```out
meta = 
  gridMetadata with metadata:
     lon: [360×1 double]
     lat: [181×1 double]
    time: [24000×1 datetime]
     run: [2×1 string]
```

This metadata object has 4 defined dimensions:

```in
defined = meta.defined
```

```out
defined = 
    "lon"
    "lat"
    "time"
    "run"
```

But these dimensions have no order:

```in
order = meta.order
```

```out
order = 
  1×0 empty string array
```

Specify an order for the dimensions. Here, we'll use a dimension order of time x lon x lat x run:

```in
orderedMeta = meta.setOrder("time","lon","lat","run")
```

```out
orderedMeta = 
  gridMetadata with metadata:
    time: [24000×1 datetime]
     lon: [360×1 double]
     lat: [181×1 double]
     run: [2×1 string]
```

Note that the dimensions are printed to the console in the appropriate order. You can also access the dimension order using the .order property:

```in
order = orderedMeta.order
```

```out
order = 
    "time"    "lon"    "lat"    "run"
```

Note that you can group the dimension names into a string vector for the same effect:

```in
order = ["time","lon","lat","run"];
orderedMeta = meta.setOrder(order)
order = orderedMeta.order
```

```out
orderedMeta = 
  gridMetadata with metadata:
    time: [24000×1 datetime]
     lon: [360×1 double]
     lat: [181×1 double]
     run: [2×1 string]
     
order = 
    "time"    "lon"    "lat"    "run"
```

Also note that you must provide each defined dimension exactly once when specifying a dimension order. Anything else will cause an error. For example:

```in
meta.setOrder("time","lon","lat")
```

```error
The dimension order must include the "run" dimension
```

```in
meta.setOrder("time","lon","lat","run","site")
```

```error
dimension name 5 ("site") is not a(n) defined dimension. Allowed values are "lon", "lat", "time", and "run".
```


# Delete dimension order

You can delete the dimension order from a metadata object by providing 0 as the first and only input. For example, create a gridMetadata object with a dimension order:

```in
lat = (-90:90)';
lon = (1:360)';
time = (datetime(1,1,1):calmonths(1):datetime(2000,12,1))';
run = ["Control";"Full-forcing"];
meta = gridMetadata('lat', lat, 'lon', lon, 'time', time, 'run', run);

meta = meta.setOrder("time","lon","lat","run")
order = meta.order
```

```out
meta = 
  gridMetadata with metadata:
    time: [24000×1 datetime]
     lon: [360×1 double]
     lat: [181×1 double]
     run: [2×1 string]
     
order = 
    "time"    "lon"    "lat"    "run"
```

Remove the dimension order from this metadata:

```in
meta = meta.setOrder(0)
order = meta.order
```

```out
meta = 
  gridMetadata with metadata:
     lon: [360×1 double]
     lat: [181×1 double]
    time: [24000×1 datetime]
     run: [2×1 string]
     
order = 
  1×0 empty string array
```

The dimensions no longer display in a custom order, and the .order property is now empty.