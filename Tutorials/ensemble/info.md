---
layout: simple_layout
title: Summarize Ensemble
---

# Support for useVariables and useMembers

The ensemble class also has several functions to facilitate use of the "useVariables" and "useMembers" commands.

#### Variable Names

You can use the "variableNames" command to return a list of all the variables stored in a .ens file:
```matlab
varNames = ens.variableNames;
```
Here, varNames is a string vector.

#### Ensemble Metadata

You can use the "metadata" command to return an ensembleMetadata object for the ensemble stored in a .ens file:
```matlab
meta = ens.metadata;
```

If you have used the "useVariables" or "useMembers" commands, you can use the "loadedMetadata" command with no inpouts to return an ensembleMetadata object for the subset of the ensemble that will be loaded:
```matlab
meta = ens.loadedMetadata;
```

Alternatively, you can provide variable names and ensemble members as the first and second inputs to return the ensembleMetadata object for an ensemble consisting of those variables and ensemble members:
```matlab
meta = ens.loadedMetadata(varNames, members);
```

#### Ensemble Members with NaN

Many of the data assimilation analyses do not permit NaN values. Consequently, it can be useful to find and exclude ensemble members that contain NaN. You can find ensemble members with NaN using the "hasnan" command.
```matlab
nanMembers = ens.hasnan;
```
Here, nanMembers is a row vector with one element per ensemble member. Elements that are true indicate that an ensemble member contains NaN elements.

You can also search for NaN elements in specific variables using the first input
```matlab
nanMembers = ens.hasnan(varNames)
```
Here, varNames is a string vector listing specific variables in a state vector ensemble. nanMembers will have one row per listed variable. If you use an empty array as the first input:
```matlab
nanMembers = ens.hasnan([]);
```
nanMembers will return information for each variable in the state vector. It will have one row per variable and variables will be in the same order as returned by the "variableNames" command.

#### Summary

You can use the "info" method to return a summary of the ensemble in a .ens file as well as a summary of the data that will be loaded. Use
```matlab
ens.info;
```
to print the summary to the console. Use:
```matlab
s = ens.info;
```
to return the summary as a structure.

[Previous](subset)---[Next]()
