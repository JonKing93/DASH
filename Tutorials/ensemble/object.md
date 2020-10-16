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

[Previous](save)---[Next](load)
