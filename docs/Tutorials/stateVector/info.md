# Summarize a state vector

With large, complex state vectors, it can be easy to lose track of all the variables, dimensions, and design options. For this reason, stateVector provides several methods to help summarize information. Specifically, you can
1. [Review variables in a state vector](#variable-names),
2. [Review the state and ensemble dimensions of a variable](#dimensions), and
3. [Get detailed summaries of variables and their dimensions](#detailed-summaries).

<br>
### Variable Names

To return a list of variables in the state vector, use
```matlab
sv.variableNames
```

<br>
### Dimensions

You can review a list of dimensions for a variable by using the "dimensions" command and providing a variable name as input. For example:
```matlab
sv.dimensions( 'T' )
```
will return the dimensions for variable "T".

To return a list of state dimensions, use either of
```matlab
sv.dimensions( variable, 'state')
sv.dimensions( variable, 's')
```

To return a list of ensemble dimensions, use any of
```matlab
sv.dimensions(variable, 'ensemble')
sv.dimensions(variable, 'ens')
sv.dimensions(variable, 'e')
```

If you specify multiple variable names, then the output will be a cell vector with one element per variable. Each element will contain the appropriate dimensions for the corresponding variable.

<br>
### Detailed summaries

You can use
```matlab
sv.info
```
to print an overview of a state vector to the console. If you provide a list of variable names as the first input, then detailed information about the dimensions of the variables will also be printed to console. For example:
```matlab
sv.info(["T","P","Tmean"])
```
will provide a detailed summary of each of the "T","P", and "Tmean" variables.

Alternatively, you can use
```matlab
[vectorSummary, variableSummaries] = sv.info( varNames )
```
to return the state vector summary as a structure, and variable summaries as a structure array instead of printing information to the console.
