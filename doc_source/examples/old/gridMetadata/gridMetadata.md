# Initialize empty metadata

```in
meta = gridMetadata
```

```out
meta = 
  gridMetadata with no metadata.
```


# Create metadata object

Examine the list of supported dimensions:

```in
supported = gridMetadata.dimensions
```

```out
supported = 
    "lon"
    "lat"
    "lev"
    "site"
    "time"
    "run"
    "var"
```

Create metadata for some of the supported dimensions. Metadata must be a matrix of numeric, logical, char, string, datetime, or cellstring data. Numeric matrices cannot contain NaN elements, and datetime matrices cannot contain NaT elements:

```
site = [20 30;
        10 10;
        30 40
        40 50];
time = (datetime(1,1,15):calmonths(1):datetime(2000,12,15))';
run = ["Full-forcing";"Control";"CO2 Ramp"];
```

Create metadata using Dimension-Name,Metadata-Value pairs as input:

```in
meta = gridMetadata('site', site, 'time', time, 'run', run)
```

```out
meta = 
  gridMetadata with metadata:
    site: [4×2 double]
    time: [24000×1 datetime]
     run: [3×1 string]
```


# Include metadata attributes

You can also include non-dimensional metadata attributes in a gridMetadata object using the "attributes" option. Metadata for attributes should be a scalar struct and may contain any fields. For example:

```in
attributes = struct('Units', "Kelvin",...
                    'date_downloaded', datetime(2015,1,1),...
                    'land_mask', true(181, 360), ...
                    'pressure', 250:250:1000);
                
meta = gridMetadata('attributes', attributes)
```

```out
meta = 
  gridMetadata with metadata:
    attributes: [1×1 struct]
```

Attributes can also be combined wth dimensional metadata using the usual Name,Value syntax:

```in
lat = (-90:90)';
lon = (1:360)';

meta = gridMetadata('lat', lat, 'lon', lon, 'attributes', attributes)
```

```out
meta = 
  gridMetadata with metadata:
           lon: [360×1 double]
           lat: [181×1 double]
    attributes: [1×1 struct]
```


# Convert struture to gridMetadata

You can also convert a struct to a gridMetadata object. If the struct has any fields that match supported dimension names, or "attributes", the fields will be converted to a gridMetadata. For example, create a structure with some metadata:

```in
lat = (-90:90)';
lon = (1:360)';
time = (datetime(1,1,15):calmonths(1):datetime(2000,12,15))';
attributes = struct('Units', "Kelvin", 'pressure', 1000);

s = struct('lat', lat, 'lon', lon, 'time', time, 'attributes', attributes)
```

```out
s = 
  struct with fields:
           lat: [181×1 double]
           lon: [360×1 double]
          time: [24000×1 datetime]
    attributes: [1×1 struct]
```

Convert the structure to a gridMetadata object:

```in
meta = gridMetadata(s)
```

```out
meta = 
  gridMetadata with metadata:
           lon: [360×1 double]
           lat: [181×1 double]
          time: [24000×1 datetime]
    attributes: [1×1 struct]
```

The struct can also include other fields, but these will not be copied into the gridMetadata object. For example:

```in
s.unsupported = 5
```

```out
s = 
  struct with fields:
                lat: [181×1 double]
                lon: [360×1 double]
               time: [24000×1 datetime]
         attributes: [1×1 struct]
        unsupported: 5
```

```in
meta = gridMetadata(s)
```

```out
meta = 
  gridMetadata with metadata:
           lon: [360×1 double]
           lat: [181×1 double]
          time: [24000×1 datetime]
    attributes: [1×1 struct]
```

Note that the "unsupported" field is ignored when converting to gridMetadata.