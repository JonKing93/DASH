# Edit dimensional metadata

Create a gridMetadata object:

```in
meta = gridMetadata('lat', (-90:90)', 'lon', (0:359)', 'time', (1:2000)');
```

```out
meta =
  gridMetadata with metadata:
     lon: [360x1 double]
     lat: [181x double]
    time: [2001x1 double]
```

Here we have created metadata for a data set with global coverage over the Common Era.

Let's update some of the metadata to reflect an updated dataset. Here, we'll

1. Restrict latitude to the Northern Hemisphere
2. Increase time to include the years 2001-2005, and
3. Use a datetime format for the time metadata

```in
lat = meta.lat;
NH = lat(lat>0);
time = (datetime(1,1,1):calyears(1):datetime(2005,1,1))';

newMeta = meta.edit('time', time, 'lat', NH)
```

```out
newMeta =
  gridMetadata with metadata:
     lon: [360x1 double]
     lat: [90x1 double]
    time: [2005x1 datetime]
```

The metadata for the lat and time dimensions has been updated.


# Edit metadata attributes

You can also edit the metadata attributes. For example, create a gridMetadata object:

```in
attributes = struct('Units', 'Kelvin', 'Pressure_levels', 1:850);
meta = gridMetadata('lat', (-90:90)', 'lon', (0:359)', 'attributes', attributes);
```

```out
meta =
  gridMetadata with metadata:
           lon: [360x1 double]
           lat: [181x double]
    attributes: [1x1 struct]
    
    Show attributes
                Units: 'Kelvin'
      Pressure_levels: [1x850 double]
```
    
Update the metadata attributes to different values:

```in
newAttributes = struct('Units', 'Celsius', 'date_downloaded', datetime(2015,1,1));

editedMeta = meta.edit('attributes', newAttributes)
```

```out
meta =
  gridMetadata with metadata:
           lon: [360x1 double]
           lat: [181x double]
    attributes: [1x1 struct]
    
    Show attributes
                Units: 'Celsius'
      date_downloaded: 01-Jan-2015
```

The metadata attributes have been changed to different values. If you would like to edit existing attributes directly, see also the "editAttributes" command.


# Add new dimension to metadata

If you want to add a dimension to a gridMetadata object, edit the metadata for that dimension.

For example, create a gridMetadata object:

```in
meta = gridMetadata('lat', (-90:90)', 'lon', (0:359)', 'time', (1:2000)');
defined = meta.defined
```

```out
meta =
  gridMetadata with metadata:
     lon: [360x1 double]
     lat: [181x double]
    time: [2001x1 double]
    
defined =
         "lon"
         "lat"
         "time"
```

This metadata object defines metadata for the lon, lat, and time dimensions. Let's add metadata for the "run" dimension to the object. We'll say our dataset is for data at a surface level:

```in
editedMeta = meta.edit('run', "surface")
defined = editedMeta.defined
```

```out
meta =
  gridMetadata with metadata:
     lon: [360x1 double]
     lat: [181x double]
    time: [2001x1 double]
     lev: "surface"
    
defined =
         "lon"
         "lat"
         "time"
         "lev"
```

The edited object now defines metadata for the "lev" dimension. Note that you can only add dimensions that are recognized by gridMetadata to a metadata object. Note that you can use:

```in
recognized = gridMetadata.dimensions
```

```out
recognized =
            "lon"
            "lat"
            "lev"
            "site"
            "time"
            "run"
            "var"
```

to return the list of recognized dimensions.

# Remove dimension from metadata

You can remove a dimension from a gridMetadata object by editing the dimension's metadata to an empty array [].

For example, create a gridMetadata object:

```in
meta = gridMetadata('lat', (-90:90)', 'lon', (0:359)', 'time', (1:2000)');
defined = meta.defined
```

```out
meta =
  gridMetadata with metadata:
     lon: [360x1 double]
     lat: [181x double]
    time: [2001x1 double]
    
defined =
         "lon"
         "lat"
         "time"
```

We can see this object defines metadata for the lon, lat, and time dimensions. Remove the time dimension by editing its metadata to an empty array:

```in
editedMeta = meta.edit('time', [])
defined = newMeta.defined
```

```out
editedMeta =
     lon: [360x1 double]
     lat: [181x double]

defined =
         "lon"
         "lat"
```

The edited metadata object no longer defines metadata for the time dimension.
