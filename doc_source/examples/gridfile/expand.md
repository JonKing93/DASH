# Increase the length of a dimension in a gridfile

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
           run:   3    (   1 to 3   )
      ...
```

We can see this gridfile manages a multi-dimensional dataset. This dataset includes a "run" dimension, which indexes 3 runs / ensemble members.

Let's expand the "run" dimension to include space for 10 runs / ensemble members:

```in
newRuns = (4:10)';
grid.expand('run', newRuns);
disp(grid)
```

```out
grid = 
      ...
      Dimension Sizes:
           lon: 360    (   0 to 359 )    
           lat: 181    ( -90 to 90  )
          time: 156    (1850 to 2005)
           run:   3    (   1 to 10  )
      ...
```

The gridfile now has 10 elements along the "run" dimension.

Note that you can only expand existing dimensions in the gridfile. Non-existent dimensions will throw an error. For example:

```in
grid.expand('lev', 1)
```

```error
"lev" is not a dimension in the gridfile. Allowed values are: "lon", "lat", "time", and "run"
```

If you would like to create a new dimension in a gridfile, see instead the "addDimension" command.