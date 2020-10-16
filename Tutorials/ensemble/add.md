---
layout: simple_layout
title: Add ensemble members
---
# Add ensemble members
You can also use an ensemble object to add more ensemble members to the ensemble stored in a .ens file. Use the "add" command and specify the number of new ensemble members to add to the file.
```matlab
ens.add( nAdd )
```
For example,
```matlab
ens = ensemble('myEnsemble.ens');
ens.add(5);
```
will add 5 more ensemble members to the state vector ensemble saved in the file "myEnsemble.ens".

### Optional: Disable progress bar

By default, the "add" command will display a progress bar as it builds new ensemble members. You can specify whether to display the progress bar using the second input
```matlab
ens.add(nAdd, showprogress)
```

Here, showprogress is a scalar logical. Set it to false to disable the progress bar. For example:
```matlab
ens.add(5, false)
```
will add 5 new ensemble members to the state vector ensemble, but will not display a progress bar.

Cool beans, that's the ensemble tutorial. If you are interested in finding specific data elements or ensemble members in a state vector ensemble, check out the [ensembleMetadata tutorial](../ensembleMetadata/welcome).

[Previous](info)---[Next](../welcome)
