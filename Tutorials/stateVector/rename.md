---
layout: simple_layout
title: Rename
---

<h1 id="vector">Rename a state vector</h3>

To rename a state vector, use the "rename" command and provide the new name as input. For example
```matlab
sv = sv.rename("A new name")
```

[jump](#rename-variables-in-a-state-vector)

# Rename variables in a state vector

To rename variables, use the "renameVariables" command and provide, in order
1. The current names of the variables being renamed, and
2. The new names of the variables

For example
```matlab
currentNames = ["T","P","Tmean"];
newNames = ["X","Y","Z"];
sv = sv.rename(currentNames, newNames);
```
would rename the "T", "P", and "Tmean" variables to "X", "Y", and "Z" respectively. Note that all new names must be valid MATLAB variable names: they must start with a letter and only include letters, numbers, and underscores.
