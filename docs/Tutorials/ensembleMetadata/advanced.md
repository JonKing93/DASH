
# Advanced topics
The following pages contain tutorials on using more advanced ensembleMetadata features.

### Summary information
You can use the following methods to return summary information for a state vector ensemble
* `ensMeta.name`: Returns the name of the metadata
* `ensMeta.variableNames`: Returns a list of variables in the state vector ensemble
* The [sizes command](sizes) can be used to return the size of a state vector ensemble, or of specific variables in the ensemble

### Metadata queries
The following pages detail options for querying metadata for:
* [Specific rows (state vector elements)](rows)
* [Specific columns (ensemble members)](columns)
* [A particular variable](variable)
* [A dimension down the entire state vector](dimension)

The [findRows command](find-rows) can also be useful for locating rows of a single variable within the entire state vector.

### Manipulating ensembles
Sometimes you might manipulate a state vector ensemble to add or remove variables and ensemble members. The following pages show how to update the metadata for such ensembles.
* [Add variables to an ensemble](append)
* [Add ensemble members](appendMembers)
* [Remove variables](remove)
* [Remove ensemble members](removeMembers)
