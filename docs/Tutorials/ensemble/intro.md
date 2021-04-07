# Saving state vector ensembles

In the stateVector tutorial, we saw how to use the [build command](../stateVector/build) to create a state vector ensemble and return it as a matrix. However, it is often useful to save the state vector ensemble to a file, rather than returning it directly as an output matrix. Common reasons for this include:

#### 1. The ensemble takes a long time to build

Some ensembles take a long time to build. This is most common when using a large number of ensemble members, data stored in many files, or OPeNDAP datasets. These slow build times are inconvenient if you frequently need to re-build the ensemble (for example, after modifying/deleting an ensemble matrix or starting work in a new Matlab session). By saving the ensemble, you can limit the slow build time to a single instance and quickly load the ensemble for future uses.

#### 2. The ensemble is too large to fit in active memory

Some state vector ensembles are too large to fit in active memory so cannot be returned as output from stateVector.build. To work with such ensembles, you should instead write them to file. As we will see in later tutorials, DASH includes several algorithms for working with very large ensembles, so you can still use these saved, large ensembles for data assimilation.

#### 3. Reusing ensembles

If you want to use a state vector ensemble (or a subset of an ensemble) in multiple studies or analyses, it can be useful to save it to file. This way, you can quickly load the ensemble whenever you start a new analysis, rather than re-designing a stateVector object and re-building the ensemble from scratch.

# The .ens file

DASH uses a ".ens" file format to save state vector ensembles. The .ens files use a special format that includes detailed metadata for the variables and ensemble members in a state vector ensemble. This metadata allows many options for interacting with saved ensembles. In particular, it allows you to

1. Load specific ensemble members,
2. Load specific variables, and
3. Add more ensemble members to a previously saved ensemble.

In the next section, we will see how to generate these files using a stateVector object.
