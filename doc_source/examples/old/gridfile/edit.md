# Edit the metadata for a gridfile dimension

Create a gridfile:

```in
grid = gridfile('my-gridfile.grid');
```

```out
grid = 
      ...
      Dimension Sizes:
          time: 156    (1850 to 2005)
           run:   3    (   1 to 3   )
      ...
```

We can see the file has "time" and "run" dimensions, and that the run metadata indexes three ensemble members.

Say we want to replace the run metadata with more informative strings. Then we can do:

```in
runs = ["control";"solar";"ghg"];
grid.edit('run', runs);
disp(grid)
```

```out
grid = 
      ...
      Dimension Sizes:
          time: 156    (     1850 to  2005)
           run:   3    ("control" to "ghg")
      ...
```

The former metadata has been replaced with the new values.

Note that you can only edit dimensions that exist in the gridfile. Non-existent dimensions will throw an error. For example:

```in
grid.edit('lon', 5)
```

```error
"lon" is not a dimension in the gridfile.
Allowed dimensions are: "time", and "run"
```

Likewise, the new metadata must have the same number of rows as the old metadata. That is, the new metadata must match the length of the dimension in the gridfile. Metadata with a different number of rows will throw an error. For example:

```in
newTimeMetadata = (1800:2005)';
grid.edit('time', newTimeMetadata);
```

```error
The number of rows in the new "time" metadata (206)
does not match the size of the "time" dimension (156) in the gridfile
```

