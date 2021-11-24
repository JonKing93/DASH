# Return the default valid range

This valid range is applied to any new data sources added to the gridfile.

```in
grid = gridfile('my-gridfile.grid');
range = grid.validRange
```

```out
range =
       [-Inf Inf]
```

# Return data source valid ranges

Use the 'sources' to return the valid range for each data source:

```in
grid = gridfile('my-gridfile.grid');
nSource = numel(grid.sources)
sourceRanges = grid.validRange('sources')
```

```out
nSource =
         5

sourceRanges =
              -Inf   Inf
              -Inf   Inf
                 0   100
              -Inf   Inf
              -999  1000
```

Alternatively, specify which sources to return valid ranges for. Either provide source names:

```in
sourceNames = ["my-source-2.mat", "my-source-3.nc", "my-source-5.txt"];
sourceFills = grid.validRange('sources', sourceNames)
```

```out
sourceFills = 
              -Inf   Inf
                 0   100
              -999  1000
```

Or the indices of sources in the gridfile:

```in
sourceIndices = [2 3 5]
sourceFills = grid.validRange('sources', sourceIndices)
```

```out
sourceFills = 
              -Inf   Inf
                 0   100
              -999  1000
```


# Set the default valid range

The new valid range is applied to all data sources in the gridfile, and to any data sources added to the gridfile in the future.

Create a new gridfile and examine the default valid range.

```in
grid = gridfile('my-gridfile.grid');
defaultRange = grid.validRange
```

```out
defaultRange =
              -Inf  Inf
```

Also examine the valid range for a data source. Note that the valid range for individual data sources can differ from the default range.

```in
sourceRange = grid.validRange('sources', 'my-data-source.mat')
```

```out
sourceRange =
             -999  999
```

Change the default valid range.

```in
newRange = [0 1000]
grid.validRange(newRange)
defaultRange = grid.validRange
```

```out
defaultRange =
              0  1000
```

Note that the valid range for the data source is updated to this new default value

```in
sourceRange = grid.validRange('sources', 'my-data-source.mat')
```

```out
sourceRange =
             0  1000
```

# Set data source valid ranges

Use the second input to apply a valid range to specific data sources. This syntax can override default gridfile valid range:

Start by creating a gridfile object. Examine default valid range, and the valid range of individual data sources:

```in
grid = gridfile('my-gridfile.grid');

defaultRange = grid.validRange
sourceRange = grid.validRange('sources')
```

```out
defaultRange =
              -Inf  Inf
              
sourceRange =
             -Inf  Inf
             -Inf  Inf
             -Inf  Inf
```

So far, the valid range for each data source matches the gridfile's default range. Next change the fill value for some of the data sources. To specify which sources to change, either provide source names or the indices of sources in the gridfile:

```
newRange = [0 1000];

% Using source names
sourceNames = ["my-source-1.mat", "my-source-2.nc"];
grid.validRange(newRange, sourceNames);

% Using source indices
sourceIndices = [1 2];
grid.validRange(newRange, sourceIndices);
```

Now re-examine the gridfile's default valid range and the range for each source:

```in
defaultRange = grid.validRange
sourceRange = grid.validRange('sources')
```

```out
defaultRange =
              [-Inf  Inf]
              
sourceRange =
                0  1000
                0  1000
             -Inf   Inf
```

The valid ranges for the two specified sources have been altered. However, the default valid range and the range for the third data source have not changed.
