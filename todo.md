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
3. Informational methods for variables

4. Add precision options into build methods
8. Restore removed ensemble members when a coupling set is incomplete
    - No need to do this because no more ensemble members can be added
9. Smart nMembers for incomplete or "all" options - decrease the size of nMembers as finite numbers of members are selected



**
Need to design loadIndices
Can directly copy state indices. No need to bother with index limits
Ensemble dimensions are the only time you need to bother with index limits
    And you only need index limits when loading multiple ensemble members simultaneously
    If loading a single ensemble member, you can use (reference index + addIndices) directly

--You should finished updating svv.indexLimits to reflect these needs
**



Write tests

Write examples



FINISH GRIDFILE:

1. Add handling for no dimensions case
    - Maybe just prohibit 0 dimensions?
    - Otherwise, need to look at grid.add and grid.loadInternal

Combine dash.gridfile.indices with dash.parse.stringsOrIndices

Consider renaming absolutePaths to preferredPath and adding switches syntax

Write examples
    gridfile