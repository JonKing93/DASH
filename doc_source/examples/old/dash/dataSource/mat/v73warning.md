# Issue v7.3 MAT-file warning

An example dataSource object:

```in
dataSource
```

```out
dataSource =
  mat with properties
    source: "example-file.mat"
    ...
```

Issue the warning:

```in
dataSource.v73warning
```

```out
File "example-file.mat" is not a version 7.3 MAT-file...
```