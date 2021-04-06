---
title: "Expand ND Array"
---

# Expand the size of a .grid file's array

Sometimes it may be necessary to increase the size of a .grid file's N-dimensional array. For example, new instrumental data may become available and increase the size of the "time" dimension. Or you may add more members to an ensemble and increase the size of the "run" dimension. To increase the size of a dimension in a .grid file, you will need to use the "expand" command. Syntax is
```matlab
grid.expand( dimension, newMetadata )
```
where
* grid is a gridfile object
* dimension is the name of the dimension being expanded, and
* newMetadata is the metadata for the new elements along the dimension.

Note that the new metadata must use the same format as the existing metadata for the dimension in the .grid file. They must have the same number of columns and have compatible data types. Sets of compatible data types are (numeric and logical), and (char, string and cellstring). Datetime metadata is only compatible with other datetime metadata.

[Advanced Topics](advanced)
