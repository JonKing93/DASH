# Add a dimension to a gridfile

Create a gridfile:

```in
grid = gridfile('my-gridfile.grid')
```

```out
grid = 
      ...
      Dimension Sizes:
           lon: 360    (   0 to 359 )    
           lat: 181    ( -90 to 90  )
          time: 156    (1850 to 2005)
      ...
```

We can see this gridfile manages a 3D dataset over latitude, longitude, and time.

Let's say we want to add a "run" dimension to the gridfile to include datasets from different ensemble members. Then:

```in
newDimension = 'run';
newMetadata = 1;
grid.addDimension(newDimension, newMetadata);

disp(grid)
```

```out
grid = 
      ...
      Dimension Sizes:
           lon: 360    (   0 to 359 )    
           lat: 181    ( -90 to 90  )
          time: 156    (1850 to 2005)
           run:   1    (   1 to 1   )
      ...
```

The gridfile now includes a "run" dimension. Note that the metadata for the new dimension must have a single row. This is because the new dimension is treated as a trailing singleton dimension in the existing data grid. Metadata with multiple rows will throw an error, for example:
    
```in
grid.addDimension('lev', [1;2;3])
```

```error
The metadata for the new "lev" dimension must have a single row, but it has 3 rows instead
```

To add a dimension to a gridfile with a length greater than 1, combine addDimension with the "expand" command. (See the next example for details)


# Add non-singleton dimension to a gridfile

To add a dimension that has a length greater than 1 to a gridfile, combine the addDimension and expand commands. For example:

Create a gridfile:

```in
grid = gridfile('my-gridfile.grid')
```

```out
grid = 
      ...
      Dimension Sizes:
           lon: 360    (   0 to 359 )    
           lat: 181    ( -90 to 90  )
          time: 156    (1850 to 2005)
      ...
```

We can see this gridfile manages a 3D dataset over latitude, longitude, and time.

Let's say we want to add a "run" dimension to index data from 10 ensemble members. Then we can do:

```in
grid.addDimension('run', 1);
grid.expand('run', (2:10)');
disp(grid)
```

```out
grid = 
      ...
      Dimension Sizes:
           lon: 360    (   0 to 359 )    
           lat: 181    ( -90 to 90  )
          time: 156    (1850 to 2005)
           run:  10    (   1 to 10  )
      ...
```