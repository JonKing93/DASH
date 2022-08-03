# Edit existing metadata attributes

Create a gridfile and examine its metadata attributes.

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

This metadata has several attributes (Units, reference-pressure, date-downloaded, and DOI). Now, change the values of several of the attributes:

```in
grid.editAttributes('DOI', 'a-different-link', 'date-downloaded', 2021.04)
attributes = grid.metadata.attributes
```

```out
attributes = 
  struct with fields:
                 Units: 'Kelvin'
    reference-pressure: 1000000
       date-downloaded: 2021.04
                   DOI: 'a-different-link'
```

The values of the specified attributes have been rewritten.

Note that you can only edit existing attribute fields. Attempting to edit non-existent fields generates an error. For example:

```in
grid.editAttributes('a-missing-field', 5)
```

```error
a-missing-field is not a metadata attribute.
Allowed values are: "Units", "reference-pressure", "date-downloaded", and "DOI".
```
