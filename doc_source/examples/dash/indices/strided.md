# Get strided indices that include requested indices

Data stored in HDF5 formatted files is accessed using strided (evenly spaced) indices, so it is often useful to find a strided set of data indices that includes requested data elements. In this way, the loaded data will include the requested dataset.

Get a strided superset of indices:

```in
indices = [8 4 10 12];
strided = dash.indices.strided(indices)
```

```out
strided =
         [4     5     6     7     8     9    10    11    12]
```

The strided indices are spaced in intervals of 2, and include all requested indices.