# Remove data sources

A gridfileSources object with entries:

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

Remove sources:

```in
sources = sources.remove([1 3])
```

```out
sources =
  gridfileSources with properties:
  
    gridfile: "my-file"
        type: ["nc"]
        ...
```
              
           