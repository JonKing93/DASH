---
layout: simple_layout
title: Posterior Index
---

# Posterior of an index

It is often useful to calculate an index from an updated ensemble and return the full posterior of the index without the posterior ensemble. For example, say you are assimilating a global, spatial temperature field in order to reconstruct a global temperature index. The full posterior of the spatial field might be too large to save, but the posterior of the index is much smaller and sufficient to quantify reconstruction uncertainty.

You can return the posterior of an index using the "index" command. Here, the most basic syntax is:
```matlab
kf = kf.index(name, ..)
```

Here "name" is a string with the name of the index. The name can only include numbers, letters, and underscores. This will cause the output structure to include a field named "index_&lt;name>" which will hold the posterior for the reconstructed index. For example, if I do
```matlab
name = 'nino34'
kf = kf.index(name, ..);

output = kf.run;
```
then the output structure will include a field named "index_nino34" that will hold the full posterior for the index. The dimensions of this field will be (Number of ensemble members x Number of updated time steps).

### Take a mean over all state vector elements

If you only provide a name as input to the "index" command, then the index will be calculated as the mean over all state vector elements. For example, say my state vector consists of a spatial, global temperature field. If I do:
```matlab
name = 'globalT';
kf = kf.index(name);

output = kf.run;
```
then the output structure will include a field named "index_globalT". This field will hold the mean of each updated ensemble member in each assimilated time step.

### Take a weighted mean

It is often more useful to take a weighted mean over the state vector. You can specify weights using the second input:
```matlab
kf = kf.index(name, weights);
```
Here, "weights" is a vector the length of the state vector. Each element holds the weight to use for the corresponding state vector elements.

##### Example 1: Area weighted index

In the previous example, it would probably be better to take a latitude-weighted mean to account for differences in grid cell areas at different latitudes. You could use an ensembleMetadata object to get the latitude of each state vector element, and then provide the appropriate weights for the index. For example:
```matlab
lats = ensMeta.dimension('lat');
weights = cosd(lats);

name = 'globalT';
kf = kf.index(name, weights);
output = kf.run;
```
Once again, the output structure will include a field named "index_globalT", but this time it will have the area-weighted global temperature index for the posterior.

##### Example 2: Principal Component Index
You may be interested in calculating the posterior index for a principal component mode. To do this, use the loading of each state vector element on the PC mode as the weight. The "index" command calculates indices using a weighted mean, so you will want multiply the loadings by their sum to remove the normalization constant.

Building on the previous example, say I calculate the first temperature EOF from the prior ensemble, and want to return the index of this mode. I could use the Matlab "pca" function to get the loadings for the first PC:
```matlab
% Load the prior
ens = ensemble('my-prior-ensemble.ens');
X = ens.load;

% Apply a latitude weight to the covariance
lats = ens.metadata.dimension('lat');
X = X .* sqrt(cosd(lats));

% Get the PC loadings
loading = pca(X', 'NumComponents', 1);
```

And then design the index using:
```matlab
name = 'PC1';
weights = loading .* sum(loading);
kf = kf.index(name, weights);

output = kf.run;
```
Here, the output structure will have a field named "index_PC1" that holds the full posterior for PC1 calculated across the updated ensemble.


### Calculate an index over specific rows

Sometimes, you may only want to calculate an index over specific state vector rows. This is common when a state vector includes multiple climate variables. Although you could set the weights of all unused rows to 0, it is often easier to directly specify which rows to use. Do this using the third input:
```matlab
kf = kf.index(name, weights, rows);
```
Here, "rows" is a vector of indices that indicate which state vector rows to use when calculating the index; it may either be a logical vector the length of the state vector, or a vector of linear indices. The [ensembleMetadata.findRows command](..\ensembleMetadata\find-rows) is often useful for finding rows that correspond to a particular variable. If using the "rows" input, then "weights" must have one element per specified row.

Building off the previous example, say I change my state vector so that it now includes a temperature variable (named "Temp"), and a precipitation variable (named "Precip"). However, I still want to calculate a global temperature index. I could do:
```matlab
rows = ensMeta.findRows('Temp');
lats = ensMeta.variable('Temp', 'lat');
weights = cosd(lats);

kf = kf.index('globalT', weights, rows);
```
This will calculate a latitude-weighted mean over the temperature variable and return it in the output structure as the field "index_globalT".

### Remove an index from output

If you previously specified an index, you can later remove it from the output by calling the "index" command and using the string `'delete'` as the second input:
```matlab
kf = kf.index(name, 'delete');
```

For example, if I add a global temperature index:
```matlab
kf = kf.index('globalT', weights, rows);
```
and later decide I don't want to calculate it, I can remove it with:
```matlab
kf = kf.index('globalT', 'delete');
```

[Previous](output)---[Next](output-workflow)
