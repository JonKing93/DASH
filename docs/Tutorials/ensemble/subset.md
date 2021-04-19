---
sections:
  - Subset an ensemble
  - Select variables
  - Select ensemble members
  - Reset
---

# Subset an ensemble

One powerful feature of ensemble objects is the ability to load or use a subset of a state vector ensemble for an analysis. In particular, you can request that only certain variables or only certain ensemble members are loaded from a file.

### Select Variables

You can select which variables will be loaded via the "useVariables" command.
```matlab
ens = ens.useVariables( varNames );
```
where varNames is a string vector that lists the variables that should be loaded. For example, if my state vector contains "T", "Tmean", and "P" variables, I could use
```matlab
ens = ens.useVariables( ["T", "P"]);
```
to indicate that only data for the "T" and "P" variables should be loaded. After using the method, the "load" and "loadGrids" commands will only load data for those variables. So if I do:
```matlab
ens = ens.useVariables(["T", "P"]);
[X, meta] = ens.load;
```
then X will not contain the Tmean variable. Likewise, the "meta" output will be updated to reflect the loaded ensemble and thus will not include the Tmean variable.

Similarly, if I do:
```matlab
ens = ens.useVariables(["T", "P"]);
s = ens.loadGrids;
```
then "s" will only contain gridded "T" and "P" variables. There will not be a "Tmean" field.

### Select Ensemble Members

You can also select which ensemble members will be loaded via the "useMembers" command:
```matlab
ens = ens.useMembers( members )
```
where members is a set of linear indices or a logical vector indicating which ensemble members to load. For example:
```matlab
members = [1 7 18 4]
ens = ens.useMembers(members)
```
specifies that the first, 7th, 18th, and 4th ensemble members should be loaded when calling "load" or "loadGrids".

### Subset metadata
You can use the "loadedMetadata" command to return an ensembleMetadata object for the data subset that will be loaded. For example, in the following call:
```matlab
members = [1 7 18 4];
ens = ens.useMembers(members);
ensMeta = ens.loadedMetadata
```
"ensMeta" will have metadata for ensemble members 1, 7, 18 amd 4.

### Reset
You can reset settings for variables by calling "useVariables" with no inputs. For example,
```matlab
ens = ens.useVariables
```
will cause all variables to be loaded.

Similarly, you can reset settings for ensemble members by calling "useMembers" with no inputs. For example:
```matlab
ens = ens.useMembers
```
will cause all ensemble members to be loaded.
