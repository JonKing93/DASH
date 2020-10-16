---
layout: simple_layout
title: Ensemble Objects
---

# Ensemble Objects

The ".ens" files use a specialized format, so we don't want to interact with them directly. Instead, we'll create an ensemble object to interact with a particular file. Create an ensemble object using the "ensemble" command. For example:
```matlab
ens = ensemble('myEnsemble.ens');
```
creates an ensemble object (named "ens") that will allow us to interact with "myEnsemble.ens".

Throughout the rest of this tutorial, I will use "ens" to refer to an ensemble object. However, feel free to use a different naming convention in your own code.

### Optional: Name the ensemble object

You can use the second input to provide a name for an ensemble object.
```matlab
ens = ensemble(filename, name);
```
Here, "name" should be a string. For example:
```matlab
ens = ensemble('myEnsemble.ens', 'demo')
```
will create an ensemble object named "demo" for the file "myEnsemble.ens". You can retrieve the name of ensemble object at any time using the "name" command:
```matlab
ens.name
```

You can also use the "rename" command to change the name of an ensemble object at any point.
```matlab
ens = ens.rename(newName)
```
where "newName" is a string.

[Previous](save)---[Next](load)
