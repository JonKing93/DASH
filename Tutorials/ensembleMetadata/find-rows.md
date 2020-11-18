---
layout: simple_layout
title: Find Rows
---

# Variable rows

Sometimes, you may want to find the state vector rows corresponding to a specific variable. For example, most proxy system models (PSMs) require specific climate variables as input, so you may want to locate a particular variable within a state vector ensemble. You can use the "findRows" command to return the rows for a particular variable.
```matlab
rows = ensMeta.findRows(varName)
```

To illustrate, let's return to example state vector ensemble that consists in order of: a "T" variable with 1000 state vector elements, a "Tmean" variable with 1 element, and a "P" variable with 1000 elements. Then for:
```matlab
rows = ensMeta.findRows('T')
```
the output rows will equal `rows = 1:1000`. By contrast:
```matlab
rows = ensMeta.findRows('Tmean')
```
will return `rows = 1001`, and
```matlab
rows = ensMeta.findRows('P')
```
will return `rows = 1002:2001`, because those are the state vector rows corresponding to each variable.

# Rows *within* a variable

Some ensembleMetadata methods return metadata for a particular variable, rather than the entire state vector. You can use this metadata to find specific rows within that variable, but will usually need to re-locate the variable's elements within the full state vector. You can provide rows *within* a variable as the second input of the "findRows" command to determine their location in the full state vector.
```matlab
stateVectorRows = ensMeta.findRows(varName, variableRows);
```

Continuing the example, let's say I want to apply a PSM to my state vector. I determine that I need the third and fifth elements of the "P" variable to run the PSM. I could do:
```matlab
rows = ensMeta.findRows("P", [3 5]);
```
to find the rows corresponding to the third and fifth element of the "P" within the full state vector. In this case, the method would return `rows = [1004 1006]` because the "P" variable starts at row 1002 of the state vector.

By contrast:
```matlab
rows = ensMeta.findRows("T", [3 5]);
```
would return `rows = [3 5]` because the third and fifth elements of the "T" variable are the third and fifth elements of the state vector. The line:
```matlab
rows = ensMeta.findRows("Tmean", [3 5])
```
would return an error because the "Tmean" variable only has a single element.

[Previous](sizes)---[Next](variable)
