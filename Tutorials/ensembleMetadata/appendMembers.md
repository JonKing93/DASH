---
layout: simple_layout
title: Append ensemble members
---

# Append metadata for additional ensemble members
Sometimes, you might append additional ensemble members to an existing state vector ensemble. When you do so, you may want to update the ensembleMetadata object to reflect the expanded ensemble. You can use the "appendMembers" command to join the metadata for two sets of ensemble members. Here the syntax is:
```matlab
ensMetaAppended = ensMeta.append(ensMeta2)
```

Here, ensMeta is the ensemble metadata object for the first set of ensemble members. The "ensMeta2" input is an ensemble metadata object for the second set of ensemble members, which are being appended to the end of the first set. Finally, the "ensMetaAppended" output is the ensembleMetadata object for the joined ensembles.

[Advanced Topics](advanced)
