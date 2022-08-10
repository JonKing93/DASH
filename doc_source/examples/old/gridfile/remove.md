# Remove data sources from a gridfile

Create a gridfile:

```in
grid = gridfile('my-gridfile.grid');
grid.dispSources
```

```out
1. my-source-1.mat
2. my-source-2.nc
3. my-source-3.txt
4. my-source-4.mat
5. my-source-5.nc
```

We can see this gridfile manages 5 data sources.

Let's remove data sources 3 and 5 from the gridfile. To do so, either provide the names of the sources to remove, or their indices:

```
% Either select sources by name
sourceNames = ["my-source-3.txt", "my-source-5.nc"];
grid.remove(sourceNames)

% Or select sources by index
sourceIndices = [3 5];
grid.remove(sourceIndices)
```

Examine the updated gridfile:

```in
sources = grid.dispSources
```

```out
1. my-source-1.mat
2. my-source-2.nc
3. my-source-4.mat
```

Data sources 3 and 5 have been removed from the catalogue.