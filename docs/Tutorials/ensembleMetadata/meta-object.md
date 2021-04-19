---
sections:
  - Metadata objects
  - From stateVector objects
  - stateVector.build
  - stateVector.add
  - Saved ensemble
  - Loaded ensemble
  - Name the metadata
---
# Metadata objects

In the DASH framework, metadata for a state vector ensemble is stored in an ensembleMetadata object. You can then use these objects to retrieve various types of metadata. There are several ways to obtain an ensembleMetadata object. Throughout this tutorial, I will use "ensMeta" to refer to an ensemble metadata object. However, feel free to use a different name in your own code.

### From stateVector objects
If you would like to examine the metadata for a state vector *before* building an ensemble, you can also call "ensembleMetadata" directly on a stateVector object.
```matlab
ensMeta = ensembleMetadata(sv);
```

<br>
### stateVector.build
When you use the "stateVector.build" method, an ensembleMetadata object for the newly built ensemble is provided as the second output:
```matlab
[~, ensMeta] = sv.build(100);
```

<br>
### stateVector.add
When you use the "stateVector.add" method, an ensembleMetadata object for the full ensemble is provided as the second output. For example:
```matlab
[X, ~, sv] = sv.build(100);
[X(:,101:105), ensMeta] = sv.add(5);
```
will return the ensembleMetadata object for the 105 member ensemble.

<br>
### Saved ensemble
If you have a state vector ensemble saved in a .ens file, you can obtain an ensembleMetadata object for the saved ensemble by creating an ensemble object and using the "metadata" command.
```matlab
ens = ensemble('my-ensemble.ens');
ensMeta = ens.metadata;
```

<br>
### Loaded ensemble
Metadata for a loaded ensemble is provided as the second output of "ensemble.load". For example, you could use:
```matlab
ens = ensemble('my-ensemble.ens');
ens = ens.useVariables('P');
ens = ens.useMembers([1 5 17]);
[X, ensMeta] = ens.load;
```
to load a subset of a saved ensemble, and the metadata for that subset.


You can also use the "loadedMetadata" command to return the metadata for the data that will be loaded from a .ens file, without actually loading any data. For example, here:
```matlab
ens = ensemble('my-ensemble.ens');
ens = ens.useVariables('P');
ens = ens.useMembers([1 5 17]);
ensMeta = ens.loadedMetadata;
```
"ensMeta" has metadata for the "P" variable, and ensemble members 1, 5, and 17.

<br>
### Name the metadata
You can add a name to an ensembleMetadata object at any point using the "rename" command and providing a name as the only input. For example:
```matlab
ensMeta.rename('A name for the metadata');
```

The name of an ensembleMetadata object can be accessed at any point using the "name" command. Continuing the example:
```matlab
ensMeta.name
```
would return "A name for the metadata".
