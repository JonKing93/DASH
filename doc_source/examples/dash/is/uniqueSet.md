# Test if vector contains repeated values

Examples that pass the test:

```in
X = [1 4 6 7];
tf = dash.is.uniqueSet(X)
```

```out
tf = 
    true
```

```in
X = ["a","Set","of","strings"];
tf = dash.is.uniqueSet(X)
```

```out
tf = 
    true
```

Examples that fail the test:

```in
X = [1:5 1];
tf = dash.is.uniqueSet(X)
```

```out
tf = 
    false
```

```in
X = ["repeated","strings","repeated"];
tf = dash.is.uniqueSet(X)
```

```out
tf = 
    false
```


# Test if matrix contains repeated rows

Set the second input to true to test if matrix rows contain repeat values:

An example that passes the test:

```in
X = [1 2;
     2 1;
     4 4];
tf = dash.is.uniqueSet(X, true)
```

```out
tf =
    true
```

An example that fails the test:

```in
X = [1 2;
     2 1;
     4 4;
     2 1];
tf = dash.is.uniqueSet(X, true)
```

```out
tf =
    false
```


# Return indices of repeated values

Indices of repeated elements in a vector:

```in
X = [1 2 3 4 2 2 7 8 2 3];
[~, repeats] = dash.is.uniqueSet(X)
```

```out
repeats =
         2  5  6  9
```

Note that the repeats are only for the first set of repeated values. In this example, 2 is the first repeated value, so indices to the repeated 3 elements are not returned.

Indices of repeated rows in a matrix:

```in
X = [1 2 3
     2 3 4
     1 2 3];
[~, repeats] = dash.is.uniqueSet(X)
```

```out
repeats = 
         1  3
```

Here, the first and third rows are repeated.
