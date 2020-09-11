---
layout: simple_layout
title: Build Ensemble
---

# Build a state vector ensemble

Once the state vector design template is finished, you are ready to build an ensemble. Use the "buildEnsemble" command and provide the desired number of ensemble members. For example
```matlab
X = sv.buildEnsemble(150)
```
will build and return a state vector ensemble with 150 ensemble members.

<br>
#### Select ensemble members sequentially

By default, "buildEnsemble" selects ensemble members at random from the reference indices. For example, say that the time dimension for monthly data over 100 years. If we make time an ensemble dimension and use the first month of each year as the reference indices
```matlab
sv = sv.design(variables, 'time', 'ensemble', 1:12:1200)
```
then
```matlab
X = sv.buildEnsemble(50)
```
will build an ensemble with 50 ensemble members and each ensemble member will be selected from the first month of a random year.

However, you can also require "buildEnsemble" to select ensemble members sequentially from the reference indices by setting the second input to false. Using the previous example:
```matlab
X = sv.buildEnsemble(50, false)
```
will build an ensemble with 50 ensemble members. The first ensemble member will be the first month of year 1. The second ensemble member will be the first month of year 2, and the 50th ensemble member will be the first month of year 50, etc.

Nice! That's the tutorial. If you'd like more control over a state vector, check out the [Advanced Topics](advanced) page.

[Previous](add)---[All Tutorials](../welcome)
