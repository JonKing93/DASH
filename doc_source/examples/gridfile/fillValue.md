# Return the default fill value

This fill value is applied to any new data sources added to the gridfile.

```in
grid = gridfile('my-gridfile.grid');
fill = grid.fillValue
```

```out
fill =
      NaN
```

# Return data source fill values

Use the 'sources' flag to return the fill value for each data source:

```in
grid = gridfile('my-gridfile.grid');
nSource = numel(grid.sources)
sourceFills = grid.fillValue('sources')
```

```out
nSource =
         5

sourceFills =
              NaN
              NaN
             -999
              NaN
             1000
```

Alternatively, specify which sources to return fill values for. Either provide source names:

```in
sourceNames = ["my-source-2.mat", "my-source-3.nc", "my-source-5.txt"];
sourceFills = grid.fillValue('sources', sourceNames)
```

```out
sourceFills = 
              NaN
             -999
             1000
```

Or the indices of sources in the gridfile:

```in
sourceIndices = [2 3 5]
sourceFills = grid.fillValues('sources', sourceIndices)
```

```out
sourceFills = 
              NaN
             -999
             1000
```
             

# Set the default fill value

The new fill value is applied to all data sources in the gridfile, and to any data sources added to the gridfile in the future.

Create a new gridfile and examine the default fill value.

```in
grid = gridfile('my-gridfile.grid');
defaultFill = grid.fillValue
```

```out
defaultFill =
             NaN
``

Also examine the fill value for a data source. Note that the fill values for individual data sources can differ from the default fill value.

```in
sourceFill = grid.fillValue('sources', 'my-data-source.mat')
```

```out
sourceFill =
            -999
```

Change the default fill value.

```in
grid.fillValue(5)
defaultFill = grid.fillValue
```

```out
defaultFill =
             5
```

Note that the fill value for the data source is updated to this new default value

```in
sourceFill = grid.fillValue('sources', 'my-data-source.mat')
```

```out
sourceFill =
            5
```

# Set data source fill values

Use the second input to apply a fill value to specific data sources. This syntax can override default gridfile fill value:

Start by creating a gridfile object. Examine default fill value, and fill values of individual data sources:

```in
grid = gridfile('my-gridfile.grid');

defaultFill = grid.fillValue
sourceFill = grid.fillValue('sources')
```

```out
defaultFill =
              -999
              
sourceFill =
            -999
            -999
            -999
```

So far, the fill value for each data source matches the gridfile's default fill value. Next change the fill value for some of the data sources. To specify which sources to change, either provide source names or the indices of sources in the gridfile:

```
newFill = 5;

% Using source names
sourceNames = ["my-source-1.mat", "my-source-2.nc"];
grid.fillValue(newFill, sourceNames);

% Using source indices
sourceIndices = [1 2];
grid.fillValue(newFill, sourceIndices);
```

Now re-examine the gridfile's default fill value and the fill value for each source:

```in
defaultFill = grid.fillValue
sourceFill = grid.fillValue('sources')
```

```out
defaultFill =
              -999
              
sourceFill =
               5
               5
            -999
```

The fill values for the two specified sources have been altered. However, the default fill value and the fill value for the third data source have not changed.
