# List recognized dimensions

Return the list of dimensions that are recognized by gridMetadata objects.

```in
recognized = gridMetadata.dimensions
```

```out
recognized = 
            "lon"
            "lat"
            "lev"
            "site"
            "time"
            "run"
            "var"
```


# Name of metadata attributes

Return a second output to get the name of the 'attributes' property:

```in
[~, attributesName] = gridMetadata.dimensions
```

```out
attributesName =
                "attributes"
```