---
layout: simple_layout
title: Rewrite Metadata
---

# Change the metadata in a .grid file

You may want to change the dimensional metadata in a .grid file to a different format. To do so, use:
```matlab
grid.rewriteMetadata(dimension, metadata)
```

where
* grid is a gridfile object
* dimension is the name of a dimension, and
* metadata is the new metadata for the dimension.

As usual, the number of metadata rows must match the size of the dimension. Metadata can be numeric, logical, char, string, cellstring, or datetime.
