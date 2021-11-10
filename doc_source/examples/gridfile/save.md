# Save a gridfile object to file

Create a gridfile object:

```
grid = gridfile('my-gridfile.grid');
```

Examine a property in the gridfile. (Here, we'll use the default fill value as an example):

```in
fill = grid.fill
```

```out
fill = 
      NaN
```

Change the object property. Note that the value in the .grid file is no longer up-to-date.

```in
grid.fill = -999;

savedValues = matfile(grid.file);
savedFill = savedValues.fill
```

```out
savedFill =
           NaN
```

Save the new values to the file:

```in
grid.save;

savedValues = matfile(grid.file);
savedFill = savedValues.fill
```

```out
savedFill =
           -999
```
