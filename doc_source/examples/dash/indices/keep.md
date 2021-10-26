# Find requested data indices in a superset of loaded elements

Specify a requested set of data indices. Use a strided superset of the indices to load data from an HDF5 format data source

```
indices = [20 12 11 10 30 55];
loaded = dash.indices.strided(indices);
```

Find the requested indices in the loaded superset

```in
keep = dash.indices.keep(indices, loaded)
```

```out
keep =
      [11     3     2     1    21    46]
```

