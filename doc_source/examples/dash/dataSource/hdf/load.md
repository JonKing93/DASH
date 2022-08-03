# Load data from a HDF file

An example dataSource object:

```in
dataSource
```

```out
dataSource =
    ...
        size:  181  360  1000
    dataType: 'single'
    ...
```

Load data from specified indices:

```in
indices = {[1 6 5 5 4], 1:360, 700:1000};
X = dataSource.load(indices);
whos('X')
```

```out
Name   Size         Class
X      5x360x301    single 
``` 