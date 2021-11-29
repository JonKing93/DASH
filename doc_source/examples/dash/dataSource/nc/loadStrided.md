# Load strided data from a NetCDF

An example dataSource object:

```in
dataSource
```

```out
dataSource =
  nc with properties
    ...
        size:  181  360  1000
    dataType: 'single'
    ...
```

Load data from strided indices:

```in
indices = {1:2:90, 1:1:360, 700:5:1000};
X = dataSource.load(indices);
whos('X')
```

```out
Name   Size         Class
X      45x360x61    single 
``` 