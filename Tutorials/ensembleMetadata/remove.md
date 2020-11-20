---
layout: simple_layout
title: Remove variables
---

# Remove metadata for specific variables
Sometimes, you might manipulate a state vector ensemble to remove some of the variables. When you do so, you may want to update the ensembleMetadata object to reflect the reduced ensemble. You can use the "remove" method to remove the metadata for the deleted variables. Here the syntax is:
```matlab
ensMeta2 = ensMeta.remove(varNames)
```
where "varNames" is a string vector that lists the variables that should be removed from the metadata. The "ensMeta2" output is the updated ensembleMetadata object for the reduced ensemble.

For example, say I have an ensembleMetadata object for a state vector with a "T", "Tmean", and "P" variable. If I do
```matlab
ensMeta2 = ensMeta.remove("Tmean")
```
then ensMeta2 will manage metadata for an ensemble that only contains a "T" and "P" variable.

[Advanced Topics](advanced)
