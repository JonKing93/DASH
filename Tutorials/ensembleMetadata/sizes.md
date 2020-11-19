---
layout: simple_layout
title: Variables and Sizes
---

# Variables and Sizes

You can use an ensembleMetadata object to return summary information about the variables in a state vector ensemble, and their sizes. This can be useful when preallocating memory, and also as a basic check that variables are the correct size.

### Variable Names
You can return a list of the variables in a state vector ensemble using the "variableNames" command.
```matlab
varNames = ensMeta.variableNames
```

Here, varNames is a string vector listing the variables in the ensemble in the order that they occur down the state vector. For example, say I have a state vector with a "T" variable, a "Tmean" variable, and a "P" variable. Then the output of the "variableNames" command will be:
```matlab
varNames = ["T"; "Tmean"; "P"];
```

### Ensemble Size
You can use the "sizes" command to return the size of the full state vector ensemble. Here, the syntax is:
```matlab
[nState, nEns] = ensMeta.sizes;
```
where nState is the number of elements down the state vector, and nEns is the number of ensemble members across the ensemble. Continuing the example, say the "T" variable has 1000 elements, the "Tmean" variable has 1 element, and the "P" variable has 1000 elements. Let's also say there are 75 ensemble members in my ensemble. In this case, nState will equal 2001 and nEns will equal 75.

### Variable Sizes
You can also use the "sizes" command to return the size of a particular variable. Here, the syntax is:
```matlab
[nState, nEns] = ensMeta.sizes( varName )
```
where varName is the name of a particular variable, and nState is the number of state vector elements for that variable. Continuing the example, if I do:
```matlab
[nState, nEns] = ensMeta.sizes("P");
```
then nState will equal 1000, because the "P" variable has 1000 state vector elements. The value of nEns will still be 75.

You can also return the sizes of multiple variables at once by providing a string vector of variable names as the input to the "sizes" command.
```matlab
[nState, nEns] = ensMeta.sizes( varNames );
```
In this case, nState will be a vector with one element per listed variable. Each element indicates the number of state vector elements for that variable. Continuing the example, if I do:
```matlab
varNames = ["T", "Tmean", "P"]
[nState, nEns] = ensMeta.sizes( varNames );
```
then the output nState will be:
```matlab
nState = [1000; 1; 1000];
```
The value of nEns will still be 75.

[Previous](meta-object)---[Next](regrid)
