---
sections:
  - State vector variables
  - Add variables
  - Auto-coupling options
  - Overlap options
---

# State vector variables

Now that we have an empty state vector, we'll want to start adding variables to it. Within the DASH framework, different variables are defined as either:
1. Describing a different climate variable, or
2. Having different spatial or temporal resolution.

For example, a gridded monthly temperature field and gridded monthly precipitation field are different variables because they describe different climate variables. Monthly precipitation and annual precipitation would be different variables because they have different temporal resolution, and gridded temperatures and global mean temperatures are different variables because they have different spatial resolution.

In my example state vector, there are 3 variables:
1. T - Gridded monthly temperature
2. Tmean - Annual, global mean temperature
3. P - Gridded monthly precipitation

<img src="\DASH\assets\images\stateVector\state-vector.svg" alt="An example state vector." style="width:80%;display:block">
Figure 1: An example state vector.

Although T and Tmean both describe temperature, they are considered different variables because they have different spatial and temporal resolution.

### Add a variable
To add a variable, use the "add" method. For each variable, provide an identifying name, as well as the gridfile that holds the necessary data, as per:
```matlab
sv = sv.add('myVariable', 'my-gridfile.grid')
```
A variable name can be anything you find useful. It DOES NOT need to be the same as the name of the variable in any data source files. Similarly, if you defined a .grid file with a "var" dimension, the variable name DOES NOT need to be same as the metadata for the "var" dimension. The only restriction on variable names is that they must be valid MATLAB variable names; they must start with a letter, and can only include letters, numbers, and underscores. Also, you cannot give multiple variables the same name. You can [rename variables](rename#rename-variable-in-a-state-vector) if you would like to change their names later. If you'd like a reminder of the variables in a state vector, you can return their names using:
```matlab
sv.variableNames
```
The .grid file name indicates which grid file includes the data needed for the variable. Note that we have not yet indicated ***which*** data in the .grid file to use for the variable; we have only indicated that the required data is some subset of the data in the given file.

You can add multiple variables at once by providing a list of variable name and a corresponding list of variable names. For example, let's say I want to add the T, Tmean, and P variables from my example state vector. Let's say that the temperature data for the T and Tmean variables is organized by "temperature.grid", and the precipitation data for the P variable is organized by "precipitation.grid". Then I could do:
```matlab
vars = ["T","Tmean","P"];
files = ["temperature.grid", "temperature.grid", "precipitation.grid"];

sv = stateVector('My Demo');
sv = sv.add(vars, files);
```

<br>
### Auto-coupling options

(Note: This is an advanced setting not necessary for most standard applications. If you would like to learn about variable coupling, please see the [variable coupling page](couple).)

You can specify whether the variable should be automatically coupled to new variables using the third input argument. By default, variables are automatically coupled to other variables. To disable this, set the third input to false:
```matlab
sv = sv.add('myVariable', 'my-gridfile.grid', false)
```

<br>
### Overlap options

(Note: This is an advanced setting not necessary for many standard applications. If you would like to learn about variable overlap, please see the [overlap page](overlap).)

You can specify whether the variable should allow overlap in state vector ensembles using the fourth input argument. By default, variables do not allow overlap. To enable overlap, set the fourth input to true:
```matlab
sv = sv.add('myVariable', 'my-gridfile.grid', [], true)
```
