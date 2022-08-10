# Add new attributes to a gridfile

Create a gridfile and examine its metadata attributes:

```in
grid = gridfile('my-gridfile.grid');
attributes = grid.metadata.attributes
```

```out
attributes =
  struct with no fields.
```

The gridfile currently has no attributes. Add some metadata attributes to the gridfile. Note that attribute names must be valid Matlab variable names. Attribute values can be anything at all:

```
grid.addAttributes('Units', 'Kelvin', ...
                   'reference-pressure', 100000,...
                   'date-downloaded', datetime(2021,1,15),...
                   'DOI', 'my-DOI-link');
```

Now re-examine the metadata attributes:

```in
attributes = grid.metadata.attributes
```

```out
attributes = 
  struct with fields:
                 Units: 'Kelvin'
    reference-pressure: 1000000
       date-downloaded: 15-Jan-2021
                   DOI: 'my-doi-link'
```

The attributes now include the added fields.