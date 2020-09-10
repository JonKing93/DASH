---
layout: simple_layout
title: Sequences
---

# Use a sequence along an ensemble dimension

To specify a sequence for a variable, use the "sequence" method. In order, you will need to provide
1. the name of the variable,
2. the name of the ensemble dimension being given a sequence,
3. [sequence indices](dimension-indices), and
4. sequence metadata.


For example:
```matlab
sv = sv.sequence('T', 'time', [0 1 2], ["June";"July";"August"]);
```
would use a 3 element sequence down the time dimension of the "T" variable, and the three sequence elements would have associated metadata of "June", "July", and "August", respectively. Note that sequence metadata may be a numeric, logical, char, string, cellstring, or datetime matrix and must have one row per sequence element. each row must be unique and may not contain NaN or NaT elements.

<br>

### Provide a sequence for multiple variables or dimensions simultaneously

To specify sequence options for multiple variables, use a string vector of variable names as the first input. To set sequence options for multiple dimensions, use a string vector of dimension names as the second argument. When this is the case, the third and fourth inputs should be cell vectors with one element per listed dimension. Each element of the third input should hold the sequence indices for the corresponding dimension, and each element of the fourth element should hold the metadata for the corresponding dimension. For example:
```matlab
dims = ["time","run"];
indices = {[0 12 24], 0:12};
meta = {["Year 1";"Year 2";"Year 3"], (1:13)''};
sv = sv.design(variableNames, dims, indices, meta);
```
would specify sequences for both the time and run dimensions.

[Previous](design)   [Next](mean)
