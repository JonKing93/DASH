# Remove select attributes from a gridfile

Create a gridfile and examine its metadata attributes:

```in
grid = gridfile('my-gridfile.grid');
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

This metadata has several attributes (Units, reference-pressure, date-downloaded, and DOI). Now remove the last three attributes:

```in
grid.removeAttributes('reference-pressure','date-downloaded','DOI')
```

```out
attributes = 
  struct with fields:
    Units: 'Kelvin'
```

Alternatively, you can group all attributes to remove into a string vector:

```in
removeFields = ["reference-pressure", "date-downloaded","DOI"];
grid.removeAttributes(removeFields)
```

```out
attributes = 
  struct with fields:
    Units: 'Kelvin'
```

which will have the same effect.

# Remove all metadata attributes

To remove all metadata attributes, provide 0 as the only input to the method. For example, create a gridfile and examine its metadata attributes:

```in
grid = gridfile('my-gridfile.grid');
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

This metadata has several attributes (Units, reference-pressure, date-downloaded, and DOI). Call the method with 0 as the only input:

```in
grid.removeAttributes(0);
attributes = grid.metadata.attributes
```

```out
attributes = 
  struct with no fields.
```

All attributes have been removed from the metadata.