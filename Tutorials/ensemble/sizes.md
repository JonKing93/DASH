---
layout: simple_layout
title: Summary Information
---

# Summary Information

One of the simplest uses of an ensembleMetadata object is to return summary information about the size and variables in an ensemble.

### Variable Names
You can return a list of variables in the ensemble using the "variableNames" command.
```matlab
varNames = ensMeta.variableNames
```
Here varNames will be a string vector listing each of the variables in the ensemble in the order that they occur down the state vector.

### Sizes
You can also use an ensembleMetadata object to return the size of the ensemble, or the size of specific variables using the "sizes" command. To return the size of the entire ensemble, use:
```matlab
[nState, nEns] = obj.sizes
```
Here nState and nEns are scalar integers. nState reports the number of elements in the state vector, which is the number of rows in the ensemble. nEns reports the number of ensemble members, which is the number of columns.

You can also use the "sizes" method to return the size of specific variables in the state vector, using the syntax:
```matlab
[nState, nEns] = obj.sizes( varNames )
```
Here varNames is a string vector containing names of certain variables in the state vector (in no particular order). nState is a vector of integers with one element per listed variable; each element corresponds to the number of state vector elements for the corresponding variable. nEns remains a scalar integer.

For example, if I have a state vector consisting of the variables "T", "Tmean", and "P" in order, and use:
```matlab
[nState, nEns] = obj.sizes("P", "T");
```
then nState will have two elements. The first element will list the number of state vector elements (rows) for the "P" variable, and the second element will list the number of state vector elements for the "T" variable.

[Previous](meta-object)---[Next](variable)
