---
layout: simple_layout
title: "Add Variables"
---

# Add variables to a state vector

Now that we have an empty state vector, we'll want to start adding variables to it. To add a variable, use the "add" method. For each variable, provide an identifying name, as well as the gridfile that holds the necessary data, as per:
```matlab
sv = sv.add('myVariable', 'my-gridfile.grid')
```
Note that the name of the variable DOES NOT need to be the same as the name of the variable in the .grid file or associated data source. Use whatever name you find useful to identify the variable in the state vector. Note that all variable names must be valid MATLAB variable names; they must start with a letter, and can only include letters, numbers, and underscores. Also, you cannot give multiple variables the same name. You can also [rename variables](rename#rename-variable-in-a-state-vector) if you would like to change their names later. If you'd like a reminder of the variables in a state vector, you can return their names using:
```matlab
sv.variableNames
```

<br>
### Optional: Set auto-coupling options

(Note: This is an advanced setting not necessary for most standard applications. If you would like to learn about variable coupling, please see the [variable coupling page](couple).)

You can specify whether the variable should be automatically coupled to new variables using the third input argument. By default, variables are automatically coupled to other variables. To disable this, set the third input to false:
```matlab
sv = sv.add('myVariable', 'my-gridfile.grid', false)
```

<br>
### Optional: Set overlap options

(Note: This is an advanced setting not necessary for many standard applications. If you would like to learn about variable overlap, please see the [overlap page](overlap).)

You can specify whether the variable should allow overlap in state vector ensembles using the fourth input argument. By default, variables do not allow overlap. To enable overlap, set the fourth input to true:
```matlab
sv = sv.add('myVariable', 'my-gridfile.grid', [], true)
```

[Previous](new)   [Next](design)
