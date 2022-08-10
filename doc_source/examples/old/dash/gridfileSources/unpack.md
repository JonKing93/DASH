# Return a sources unmerged/merged dimensions

An example gridfileSources catalogue:

```in
sources
```

```out
sources =
  gridfileSources with properties:
  
    gridfile: "my-file"
        type: ["mat"  "nc"  "text"]
        ...
```

Return merged/unmerged dimensions for a data source:

```in
[dims, size, mergedDims, mergedSize, mergeMap] = sources.unpack(2)
```

```out
dims = 
      "lat"  "lon"  "time"
size =
      181  360  1000
mergedDims = 
            "site"  "time"
mergedSize =
            65160  1000
mergeMap =
          1  1  2
```
