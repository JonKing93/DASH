# Add attributes

Create an example gridMetadata object:

```in
attributes = struct('Units', 'Kelvin');
meta = gridMetadata('attributes', attributes);
```

```out
meta = 
  gridMetadata with metadata:
    attributes: [1×1 struct]

  Show attributes
       Units: 'Kelvin'
```

Add two new attributes to the metadata:

```in
meta = meta.addAttributes('date_downloaded', datetime(2015,1,1), 'pressure', 1000)
```

```out
meta = 
  gridMetadata with metadata:
    attributes: [1×1 struct]

  Show attributes
              Units: 'Kelvin'
    date_downloaded: 01-Jan-2015
           pressure: 1000
```

The new "date_downloaded" and "pressure" attributes have been added to the metadata.