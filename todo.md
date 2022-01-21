TODO:

1. positive integers is weird
4. link to other pages in examples markdown
    - gridfile.expand with gridfile.addDimension (in examples)
    - gridMetadata.edit with gridMetadata.editAttributes
6. Remove note from gridfile.buildSources
7. dataSourceFailed error in gridfile.load
8. Misc sections, both for classes and functions
   -Options to include graphics
9. Remove "throws" from non-assert calls
    -Or treat throws in a more consistent way through the docs


STATE VECTOR
1. Verbosity toggle
2. Constructor documentation
    - Add link once "label" method is complete
    - Add verbosity details

3. Method to return metadata along a dimension
    - Wrap as getter into "metadata" method
4. Update coupled variables in design
5. Treat variables with different dimensions
    -For update coupled variables -- possibly ignore dimensions?
    -Otherwise, add option to ignore dimensions in dimensionIndices, likely coupled with check that name is at least 1 dimension
6. Should probably add getter options to all designs
7. Informational methods for variables
8. Update sv.metadata documentation on what the metadata is actually used for
9. Auto couple?...


FINISH GRIDFILE:

Combine dash.gridfile.indices with dash.parse.stringsOrIndices

Consider renaming absolutePaths to preferredPath and adding switches syntax

Write examples
    gridfile