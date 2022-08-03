# Edit metadata attributes

Create an example gridMetadata object:

```in
attributes = struct('Units', 'Kelvin',...
                     'pressure', 1000,...
                     'date_downloaded', datetime(2015,1,1));
meta = gridMetadata('attributes', attributes)
```

```out
meta = 
  gridMetadata with metadata:
    attributes: [1×1 struct]

  Show attributes
              Units: 'Kelvin'
           pressure: 1000
    date_downloaded: 01-Jan-2015
```

Edit the values for two of the metadata attributes:

```in
meta = meta.editAttributes('Units', "Celsius", ...
                           'pressure', 250:250:1000)
```

```out
meta = 
  gridMetadata with metadata:
    attributes: [1×1 struct]

  Show attributes
              Units: "Celsius"
           pressure: [250 500 750 1000]
    date_downloaded: 01-Jan-2015
```

The "Units" and "pressure" attributes have been updated.

Note that you can only edit existing metadata attributes. Attempting to edit an non-existent attribute will cause an error. For example:

```in
meta = meta.editAttributes('not_an_attribute', 5)
```

```error
Attribute name ("not_an_attribute") is not a(n) existing attribute field. 
Allowed values are "Units", "pressure", and "date_downloaded".
```
