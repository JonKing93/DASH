# List defined dimensions

Return the list of dimensions with metadata for a gridMetadata object:

```in
attributes = struct('Units','kelvin');
meta = gridMetadata('lat', (-90:90)', 'lon', (0:359)', 'attributes', attributes);

defined = meta.defined
```

```out
defined =
         "lon"
         "lat"
```

This metadata object defines metadata for the lon and lat dimensions. Note that metadata attributes are not associated with any dimension, so are not returned here.



