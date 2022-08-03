# Remove specified attributes

You can remove attributes from a metadata object by listing the attribute names as input. For example, create a gridMetadata object:

```in
attributes = struct('Units', 'Kelvin', 'Pressure_levels', 1:850, 'date_downloaded', datetime(2015,1,1));
meta = gridMetadata('lat', (-90:90)', 'lon', (0:359)', 'attributes', attributes)
```

```out
meta =
  gridMetadata with metadata:
           lon: [360x1 double]
           lat: [181x double]
    attributes: [1x1 struct]
    
    Show attributes
                Units: 'Celsius'
      Pressure_levels: [1x850 double]
      date_downloaded: 01-Jan-2015
```

This object has 3 attributes: Units, Pressure_levels, and date_downloaded. Remove them all at once:

Let's remove the Pressure_levels and date_downloaded attributes:

```in
editedMeta = meta.removeAttributes('date_downloaded','Pressure_levels')
```

```out
editedMeta =
  gridMetadata with metadata:
           lon: [360x1 double]
           lat: [181x double]
    attributes: [1x1 struct]
    
    Show attributes
                Units: 'Celsius'
```

The edited metadata no longer has the two attribute fields.

Alternatively, group the names of fields you wish to remove into a string vector. For example:

```in
names = ["Pressure_levels","date_downloaded"];
editedMeta = meta.removeAttributes(names)
```

```out
editedMeta =
  gridMetadata with metadata:
           lon: [360x1 double]
           lat: [181x double]
    attributes: [1x1 struct]
    
    Show attributes
                Units: 'Celsius'
```

has the same effect as the first syntax.

# Remove all attributes

Providing 0 as the only input will remove all metadata attributes. For example, create a gridMetadata object:

```in
attributes = struct('Units', 'Kelvin', 'Pressure_levels', 1:850, 'date_downloaded', datetime(2015,1,1));
meta = gridMetadata('lat', (-90:90)', 'lon', (0:359)', 'attributes', attributes)
```

```out
meta =
  gridMetadata with metadata:
           lon: [360x1 double]
           lat: [181x double]
    attributes: [1x1 struct]
    
    Show attributes
                Units: 'Celsius'
      Pressure_levels: [1x850 double]
      date_downloaded: 01-Jan-2015
```

This object has 3 attributes: Units, Pressure_levels, and date_downloaded. Remove them all at once:

```in
editedMeta = meta.removeAttributes(0)
```

```out
editedMeta =
  gridMetadata with metadata:
           lon: [360x1 double]
           lat: [181x double]
```

The metadata no longer has any attributes.