# Supported transformations

This section gives a quick overview of supported transformations and their parameters.

Natural Logarithm:

```
grid.transform('ln');
grid.transform('ln', []);
```

Base-10 or Natural Logarithm:

```
grid.transform(log, 10)
grid.transform(log, 'e')
```

Exponential:

```
grid.transform('exp');
grid.transform('exp', []);
```

Raise to power:

```
% Power may be any numeric scalar
grid.transform('power', power);
```

Add constant:

```
% Constant may be any numeric scalar
grid.transform('plus', constant);
```

Multiply by constant:

```in
% Constant may be any numeric scalar
grid.transform('times', constant);
```

Linear transformation:  Y = a + bX

```
% a and b may be any numeric scalars
constants = [a, b];
grid.transform('linear', constants)
```

No transformation (default):

```
grid.transform('none');
grid.transform('none', []);
```


# Return the default transformation

This transformation is applied to any new data sources added to the gridfile.

```in
grid = gridfile('my-gridfile.grid');
[transform, parameters] = grid.transform
```

```out
transform =
           'log'
           
parameters =
            [10  NaN]
```



# Return data source transformations

Use the 'sources' flag to return the transformation for each data source:

```in
grid = gridfile('my-gridfile.grid');
nSource = numel(grid.sources)
[sourceTransforms, sourceParams] = grid.transform('sources')
```

```out
nSource =
         5

sourceTransforms =
                 "none"
                 "none"
                 "log"
                 "none"
                 "linear"

sourceParams =
              NaN  NaN
              NaN  NaN
               10  NaN
              NaN  NaN
                5  100
```

Alternatively, specify which sources to return transformations for. Either provide source names:

```in
sourceNames = ["my-source-2.mat", "my-source-3.nc", "my-source-5.txt"];
[sourceTransforms, sourceParams] = grid.transform('sources', sourceNames)
```

```out
sourceTransforms =
                 "none"
                 "log"
                 "linear"

sourceParams =
              NaN  NaN
               10  NaN
                5  100
```

Or the indices of sources in the gridfile:

```in
sourceIndices = [2 3 5]
sourceFills = grid.transform('sources', sourceIndices)
```

```out
sourceTransforms =
                 "none"
                 "log"
                 "linear"

sourceParams =
              NaN  NaN
               10  NaN
                5  100
```




# Set the default transformation

The new transformation is applied to all data sources in the gridfile, and to any data sources added to the gridfile in the future.

Create a new gridfile and examine the default transformation.

```in
grid = gridfile('my-gridfile.grid');
[defaultTransform, defaultParams] = grid.transform
```

```out
defaultTransform =
                  "none"
                  
defaultParams =
               NaN  NaN
```

Also examine the transformation for a data source. Note that the transformations for individual data sources can differ from the default transformation.

```in
[sourceTransform, sourceParams] = grid.transform('sources', 'my-data-source.mat')
```

```out
sourceTransform =
                 "log"
                 
sourceParameters =
                  10  NaN
```

Change the default transformation:

```in
grid.transform('times', 1000)
[defaultTransform, defaultParams] = grid.transform
```

```out
defaultTransform =
                  "times"
                  
defaultParams =
               1000  NaN
```

Note that the transformation for the data source is updated to the new default value:

```in
[sourceTransform, sourceParams] = grid.transform('sources', 'my-data-source.mat')
```

```out
sourceTransform =
                 "times"
                 
sourceParams =
                  1000  NaN
```


# Set data source transformations

Use the second input to apply a transformation to specific data sources. This syntax can override default gridfile transformations:

Start by creating a gridfile object. Examine the default transformation, and transformations of individual data sources:

```in
grid = gridfile('my-gridfile.grid');

[defaultTransform, defaultParams] = grid.transform
[sourceTransform, sourceParams] = grid.transform('sources')
```

```out
defaultTransform =
                  "none"

defaultParams =
               NaN  NaN

sourceTransform =
                 "none"
                 "none"
                 "none"

sourceParams = 
              NaN  NaN
              NaN  NaN
              NaN  NaN
```

So far, the transformation for each data source matches the gridfile's default transformation. Next change the transformation for some of the data sources. To specify which sources to change, either provide source names or the indices of sources in the gridfile:

```
newTransform = "log";
newParams = 10;

% Using source names
sourceNames = ["my-source-1.mat", "my-source-2.nc"];
grid.transform(newTransform, newParams, sourceNames);

% Using source indices
sourceIndices = [1 2];
grid.transform(newTransform, newParams, sourceIndices);
```

Now re-examine the gridfile's default transformation and the transformation for each source:

```in
[defaultTransform, defaultParams] = grid.transform
[sourceTransform, sourceParams] = grid.transform('sources')
```

```out
defaultTransform =
                  "none"

defaultParams =
               NaN  NaN

sourceTransform =
                 "log"
                 "log"
                 "none"

sourceParams = 
               10  NaN
               10  NaN
              NaN  NaN
```

The transformations for the two specified sources have been altered. However, the default transformation and the transformation for the third data source have not changed.
