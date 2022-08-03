# Create a delimited text dataSource

An example delimited text file

```in
file = 'example-file.txt';
fprintf(fileread('test.txt'))
```

```out
Var1, Var2, Var3
1,2,3
4,5,6
7,8,9
```

Create a dataSource:

```in
dataSource = dash.dataSource.nc(file, 'NumHeaderLines', 1)
```

```out
dataSource =
  text with properties
    ...
```