# Load data from a delimited text file

An example dataSource object:

```in
dataSource
```

```out
dataSource =
  text with properties
    ...
        size:  181  360
    dataType: 'double'
    ...
```

Load data from specified indices:

```in
indices = {[1 6 5 5 4], 1:360};
X = dataSource.load(indices);
whos('X')
```

```out
Name   Size         Class
X      5x360        double
``` 