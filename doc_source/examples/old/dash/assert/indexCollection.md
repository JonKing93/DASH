# Index vector

Allow user to provide indices directly for a single dimension:

```in
indices = [true, false, true, true];
nDims = 1;
dimLength = 4;

indices = dash.assert.indexCollection(indices, nDims, dimLength)
```

```out
indices = 
  1x1 cell array
    {3x1 double}
```

The indices are returned in a cell array.

Also allow the indices already organized in a cell:

```in
indices = [true, false, true, true];
indices = {indices};
nDims = 1;
dimLength = 4;

indices = dash.assert.indexCollection(indices, nDims, dimLength)
```

```out
indices = 
  1x1 cell array
    {3x1 double}
```

# Cell vector of indices

Indices for more than one dimension must be organized in a cell vector. Indices can be a mix of logical vectors and linear index vectors.

```in
indices1 = [true;false;true;true];
indices2 = [1:5, 18];
indices3 = [1;6;19;5];

indices = {indices1, indices2, indices3};
nDims = 3;
dimLength = [4, 100, 20];

indices = dash.assert.indexCollection(indices, nDims, dimLength)
```

```out
indices =
  1x3 cell array
    {4x1 double}  {6x1 double}  {4x1 double}
```

Each set of indices is converted to a column vector of linear indices.

# Invalid collection

The number of sets of indices must match the number of dimensions. In this example, there are 2 sets of indices, but 3 dimensions:

```in
indices = {[true;false;true], 1:5};
nDims = 3;
dimLengths = [3 5];

dash.assert.indexCollection(indices, nDims, dimLengths)
```

```error
input must have 3 elements, but has 2 elements instead
```


# Invalid indices

Indices must be valid relative to the length of the indexed dimension. In this example, the first dimension has a length of 5, but only 4 logical indices are provided:

```in
indices = {[true;false;false;true], 1:20};
nDims = 2;
dimLengths = [5, 20];

dash.assert.indexCollection(indices, nDims, dimLengths)
```

```error
Indices for indexed dimension 1 is a logical vector, 
so it must be the length of indexed dimension 1 (5), 
but it has 4 elements instead.
```


# Customize error

You can provide custom names for the dimensions in error messages and also customize the error ID.

```in
dimNames = ["lat","lon","time"];
header = "my:header";

invalidIndices = {[true;true], 1, 1};
nDims = 3;
dimLengths = [181 360 1000];

dash.assert.indexCollection(invalidIndices, nDims, dimLengths, dimNames, header);
```

```error
Indices for the "lat" dimension is a logical vector,
so it must be the length of the "lat" dimension (181),
but it has 2 elements instead.
```

Also examine the error ID:

```in
ME = lasterror;
ID = ME.identifier
```

```out
ID =
    'my:header'
```