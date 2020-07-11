---
layout: simple_layout
---

# Load data from a .grid file

#### Load all data
To load the entire N-Dimensional array use
```matlab
[X, Xmeta] = grid.load;
```
This returns the N-dimensional array (X) and the metadata associated with each dimension of the array (Xmeta). The order of the metadata fields will match the order of the dimensions in X.

<br>

#### Request Specific Dimension Order
When you call grid.load with no inputs, the order of the dimensions of the returned array are determined by an internal gridfile method. However, you can instead request that the array be returned with a specific dimension order by specifying a dimension order as the first input. For example:
```matlab
[X, Xmeta] = grid.load( ["lat","lon","time"] )
```
will return the array with a dimension order of (latitude x longitude x time). If you do not specify all the dimensions in the .grid file, gridfile will determine the order of the remaining dimensions using an internal method. As always, the order of the metadata fields will match the order of the dimensions in X.

<br>

#### Load Data Subset
Many dataset are too large to load into memory all at once. Instead, we'll often want to load a small subset of a larger dataset. In gridfile, this is accomplished by querying .grid file metadata for specific values. To access metadata use:
```matlab
meta = grid.metadata;
```
The returned structure contains the metadata for the specified .grid file. Each field of the structure contains the metadata for one dimension. You can use this structure to determine the indices of desired data elements within the .grid file. For example, if we want data values from the Northern Hemisphere, we could do:
```matlab
NH = meta.lat > 0;
```
Or if we want values after 1800 CE
```matlab
post1800 = meta.time > 1800;
```
Or values at a certain height
```matlab
high = meta.lev == 250;
```
The possibilities are endless!

Once we have determined the indices of desired data elements, we can request that the .grid file loads only those elements. For example,
```matlab
[X, Xmeta] = grid.load(["lat","lev","time"], {NH, high, post1800});
```
will load Northern Hemisphere temperatures values at a height of 250 after 1800 CE. The output data will be (latitude x level x time) and Xmeta will only contain metadata for this data subset. Note that the requested indices must occur in the same order as the specified dimensions. Gridfile will load all elements of dimensions that are not specified. If you want to specify a dimension order, but only want to subset a few dimensions, you can use an empty array to load every element from a dimension. For example:
```matlab
[X, Xmeta] = grid.load(["lat","lon","lev"], {NH, [], high});
```
will return X as a (latitude x longitude x level) array and will load every element along the longitude dimension.

<br>

#### Optional: Start, Count, Stride Syntax
gridfile.load also supports the start/count/stride syntax as an alternative to specifying indices. Syntax is
```matlab
grid.load(dimensions, start, count, stride)
```
where start, count and stride are vectors with one element per specified dimension. Start indicates the first index from which to start loading values. Count indicates the number of elements to load along the dimension, and stride indicates the inter-element spacing. If an element of count is Inf, keeps loading values until reaching the end of the dimension. For example:
```matlab
grid.load(["lat","lon"], [1 5], [6, Inf], [3 4])
```
will load 6 latitude elements, starting with the first element and loading every third element after that. This will also load every fourth longitude element from the fifth element to the end of the dimension.

Nice! That's the tutorial. If you'd like more control over gridfile, check out the [Advanced Topics](\DASH\gridfile\advanced) page.

[Previous](\DASH\gridfile\add) [Next](\DASH\gridfile\advanced)
