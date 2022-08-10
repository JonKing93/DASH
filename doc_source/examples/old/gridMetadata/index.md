# Return metadata at indexed rows

Create an example gridMetadata object:

```in
site = [(1:10)', (101:110)'];
time = (1900:2000)';
run = ["Full-forcing";"Control";"CO2 Ramp"];
meta = gridMetadata('site', site, 'time', time, 'run', run)
```

```out
meta = 
  gridMetadata with metadata:
    site: [10×2 double]
    time: [101×1 double]
     run: [3×1 string]
```

Return metadata at indexed metadata rows. Both linear and logical indices are allowed:

```in
siteIndices = [9 2 6 2 1];
timeIndices = 1:50;
runIndices = [true false true];

indexedMeta = meta.index('site', siteIndices, ...
                  'time', timeIndices, ...
                  'run', runIndices);
```

```out
indexedMeta = 
  gridMetadata with metadata:
    site: [5×2 double]
    time: [50×1 double]
     run: [2×1 string]
```

The metadata now only holds the number of indexed metadata rows along each dimension. Examine the indexed metadata along each dimension:

```in
site = indexedMeta.site
time = indexedMeta.time
run = indexedMeta.run
```

```out
site = 
      9  109
      2  102
      6  106
      2  102
      1  101
      
time = 
      1900
      1901
      ...
      1948
      1949
      
run = 
     "Full-forcing"
     "CO2 Ramp"
```

The metadata along each dimension has been updated to the indexed rows.
     
Alternatively, group the dimension names in a string vector, and the indices in a cell vector for the same effect:

```in
dimensions = ["site","time","run"];
indices = {siteIndices, timeIndices, runIndices};

indexedMeta = meta.index(dimensions, indices)
```

```out
indexedMeta = 
  gridMetadata with metadata:
    site: [5×2 double]
    time: [50×1 double]
     run: [2×1 string]
```
