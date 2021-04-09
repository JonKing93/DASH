
# Metadata objects

In the DASH framework, metadata for a state vector ensemble is stored in an ensembleMetadata object. You can then use these objects to retrieve various types of metadata. There are several ways to obtain an ensembleMetadata object. Throughout this tutorial, I will use "ensMeta" to refer to an ensemble metadata object. However, feel free to use a different name in your own code.

### Before building an ensemble
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
If you are only loading a subset of a state vector ensemble from a .ens file, you can get the ensembleMetadata object for the loaded subset using the "loadedMetadata" command. For example:
```matlab
ens = ensemble('my-ensemble.ens');
ens = ens.useVariables('P');
ens = ens.useMembers([1 5 17]);
ensMeta = ens.loadedMetadata;
```
will return the ensemble metadata object for a state vector ensemble that only includes the "P" variable ad ensemble members 1, 5, and 17.

Additionally, metadata for a loaded ensemble is provided as the second output of "ensemble.load". For example, you could instead use:
```matlab
ens = ensemble('my-ensemble.ens');
ens = ens.useVariables('P');
ens = ens.useMembers([1 5 17]);
[X, ensMeta] = ens.load;
```
to load both the subset of the ensemble, and the metadata for the subset, with one command.

<br>
# Name the metadata
When you create an ensembleMetadata object from a stateVector, you can optionally give the metadata an identifying name using the second input:
```matlab
ensMeta = ensembleMetadata(sv, name);
```

For example, I could do:
```matlab
ensMeta = ensembleMetadata(sv, 'My demo ensemble')
```
The name of ensembleMetadata can be accessed using the "name" command. Continuing the example:
```matlab
ensMeta.name
```
would return "My demo ensemble".

You can rename the ensembleMetadata at any point using the "rename" command and providing a new name as the only input. For example
```matlab
ensMeta.rename('A new name');
```
will change the name of the metadata to "A new name".