---
sections:
  - Coupled variables
  - Automatic coupling
  - Uncouple variables
  - Couple variables
---
# Coupled variables

Usually, when we build a state vector ensemble, we want the variables in each ensemble member to share the same ensemble dimension metadata. For example, say I have a state vector with two variables: temperature (T) and precipitation (P) and that "time" is the ensemble dimension. If the temperature data for ensemble member 1 is selected from Year 7, then I probably want the precipitation data for ensemble member 1 to be from Year 7. Likewise, if temperature in ensemble member 2 is from Year 19, then the precipitation data for ensemble member 2 should usually be from Year 19.

We can see here that T and P should share the same time metadata for each ensemble member, and this link is known as "coupling". When variables are coupled, they are required to use the same ensemble dimensions. Also, each ensemble member is required to use the same ensemble dimension metadata for each set of coupled variables. In most applications, we want all variables coupled to one another; this way, all the variables in an ensemble member are from the same data subset. Consequently, variables in a state vector are automatically coupled to newly added variables by default.

<br>
### Automatic coupling

You can disable automatic coupling for a variable when you first add it to the state vector. (See [here](add#optional-set-auto-coupling-options) for a refresher). However, you can also adjust this setting later using the "autoCouple" method. Use
```matlab
sv = sv.autoCouple( variableName, false)
```
to disable auto-coupling and
```matlab
sv = sv.autoCouple(variableName, true)
```
to re-enable it.

<br>
### Uncouple variables

You can uncouple variables in a state vector by using the "uncouple" method and providing a list variable names. For example
```matlab
vars = ["T", "P", "Tmean"];
sv = sv.uncouple( vars );
```
would uncouple the "T", "P", and "Tmean" variables.

<br>
### Couple variables

You can couple variables using the "couple" method and providing a list of variable names. For example,
```matlab
vars = ["T","P","Tmean"];
sv = sv.couple(vars);
```
would couple the "T", "P", and "Tmean" variables. When you couple variables, their ensemble dimensions will be matched to those of the first listed variable. So in this example, the ensemble dimensions of "P" and "Tmean" will be set to match those of "T".
