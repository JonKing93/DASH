---
layout: simple_layout
title: Find Rows
---

# Variable rows

Sometimes, you may want to find the state vector rows corresponding to a specific variable. For example, most proxy system models (PSMs) require specific climate variables as input, so you may want to locate a particular variable within a state vector ensemble. You can use the "findRows" command to return the rows for a particular variable.
```matlab
rows = ensMeta.findRows(varName)
```

To illustrate, let's return to example state vector ensemble that consists in order of: a "T" variable with 1000 state vector elements, a "Tmean" variable with 1 element, and a "P" variable with 1000 elements.

#### T
In this example, the line:
```matlab
rows = ensMeta.findRows('T')
```
will return
```matlab
rows = 1:1000
```
<br>
#### Tmean
By contrast:
```matlab
rows = ensMeta.findRows('Tmean')
```
will return
```matlab
rows = 1001
```
<br>
#### P
Finally,
```matlab
rows = ensMeta.findRows('P')
```
will return
```matlab
rows = 1002:2001
```
because those are the state vector rows corresponding to each variable.

<br>
# Rows *within* a variable

Some ensembleMetadata methods return metadata for a particular variable, rather than the entire state vector. You can use this metadata to find specific rows within that variable, but will usually need to locate the variable's rows within the full state vector. If you provide rows within a variable as the second input, the "findRows" command will return their location in the full state vector.
```matlab
stateVectorRows = ensMeta.findRows(varName, variableRows);
```
<br>
#### P
Continuing the example, let's say I want to apply a PSM to my state vector. I determine that I need the third and fifth rows of the "P" variable to run the PSM. I could do:
```matlab
rows = ensMeta.findRows("P", [3 5]);
```
to find the rows corresponding to the third and fifth element of the "P" within the full state vector. In this case, the method would return
```matlab
rows = [1004 1006]
```
because the "P" variable starts at row 1002 of the state vector.

<br>
#### T
By contrast:
```matlab
rows = ensMeta.findRows("T", [3 5]);
```
would return
```matlab
rows = [3 5]
```
because the third and fifth rows of the "T" variable are the third and fifth rows of the state vector.

<br>
#### Tmean
The line:
```matlab
rows = ensMeta.findRows("Tmean", [3 5])
```
would return an error because the "Tmean" variable only has a single row.

[Previous](regrid)---[Next](variable)
