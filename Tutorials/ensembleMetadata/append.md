---
layout: simple_layout
title: Append variables
---

# Append metadata for additional variables
Sometimes, you might have an ensemble of state vector variables and append a second set of variables to it. When you do so, you may want to update the ensembleMetadata object to reflect the expanded ensemble. You can use the "append" command to join the metadata for two sets of state vector variables. Here the syntax is:
```matlab
ensMetaAppended = ensMeta.append(ensMeta2)
```

Here, ensMeta is the ensemble metadata object for the first set of state vector variables. The "ensMeta2" input is an ensemble metadata object for the second set of state vector variables, which is being appended to the end of the first set. Finally, the "ensMetaAppended" output is the ensembleMetadata object for the joined ensembles.

[Advanced Topics](advanced)
