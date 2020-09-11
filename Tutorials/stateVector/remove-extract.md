---
layout: simple_layout
title: Remove or Extract Variables
---

# Removing or extracting variables

Sometimes, it may be useful to only use a subset of variables in a saved state vector template. There are two ways to obtain a subset of variables from an existing state vector: either by removing unwanted variables or extracting desired variables.

### Remove

To remove variables from a state vector, use the "remove" method and specify the names of the variables you want to remove. For example
```matlab
sv = sv.remove(["T", "P", "Tmean"])
```
will remove the "T", "P", and "Tmean" variables from a state vector.

### Extract

To extract desired variables from a state vector, use the "extract" method and specify the names of the variables you want to extract. For example
```matlab
sv = sv.extract(["T","P","Tmean"])
```
will limit a state vector to only including the "T", "P", and "Tmean" variables.
