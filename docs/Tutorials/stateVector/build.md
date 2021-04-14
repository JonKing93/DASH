---
sections:
  - Build a state vector ensemble
  - Select ensemble members sequentially
  - Save to file
  - Disable progress bar
---

# Build a state vector ensemble

Once the state vector design template is finished, you are ready to build an ensemble. Use the "build" command and provide the desired number of ensemble members. For example
```matlab
X = sv.build(150)
```
will build and return a state vector ensemble with 150 ensemble members.

<br>
#### Select ensemble members sequentially

By default, "build" selects ensemble members at random from the reference indices. For example, say that the time dimension for monthly data over 100 years. If we make time an ensemble dimension and use the first month of each year as the reference indices
```matlab
sv = sv.design(variables, 'time', 'ensemble', 1:12:1200)
```
then
```matlab
X = sv.build(50)
```
will build an ensemble with 50 ensemble members and each ensemble member will be selected from the first month of a random year.

However, you can also require "build" to select ensemble members sequentially from the reference indices by setting the second input to false. Using the previous example:
```matlab
X = sv.build(50, false)
```
will build an ensemble with 50 ensemble members. The first ensemble member will be the first month of year 1. The second ensemble member will be the first month of year 2, and the 50th ensemble member will be the first month of year 50, etc.

### Save to file
You can use the third and fourth inputs to save the ensemble to a .ens file. [This syntax](../ensemble/save) is detailed in the tutorial for the "ensemble" class.

### Disable progress bar
By default, the "build" command will display a progress bar as it builds new ensemble members. You can specify whether to display the progress bar using the fifth input
```matlab
X = sv.build(nEns, random, [], [], showprogress)
```

Here, showprogress is a scalar logical. Set it to false to disable the progress bar. For example:
```matlab
X = sv.build(50, false, [], [], false)
```
will build the ensemble without displaying the progress bar.

Nice! That's the tutorial. If you'd like more control over a state vector, check out the [Advanced Topics](advanced) page.