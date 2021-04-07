
# Creating a .ens file

In the stateVector tutorial, we showed how to use the [build command](../stateVector/build) to build a state vector ensemble. Recall that the first input specifies the number of ensemble members to select, and that the second input specifies whether to select ensemble members sequentially or at random.
```matlab
X = sv.build(nEns, random);
```

When fewer than three inputs are provided, the "build" command returns the state vector ensemble directly as a matrix. However, you can use the third input to specify the name of a .ens file in which to save the ensemble.
```matlab
sv.build(nEns, random, filename)
```
Here, filename is a string specifying the name of the .ens file. For example,
```matlab
sv.build(15, true, 'myEnsemble.ens');
```
will build an ensemble with 15 randomly selected ensemble members and save the ensemble to a file named "myEnsemble.ens". If the filename does not end in a ".ens" extension, then the "build" command will automatically add one. For example
```matlab
sv.build(15, true, 'myEnsemble');
```
will also save the built ensemble to file "myEnsemble.ens". Note that .ens files will always be written to the current directory.

### Optional: Overwrite existing .ens files

By default, the "build" command will not let you overwrite existing .ens files. However, you can change this option using the fourth input.
```matlab
sv.build(nEns, random, filename, overwrite)
```
Here, overwrite is a scalar logical. Set it to true to allow the method to overwrite existing files. For example:
```matlab
sv.build(15, true, 'myEnsemble.ens', true)
```
will overwrite any data in a previously existing file named "myEnsemble.ens".
