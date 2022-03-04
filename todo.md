TODO:

0. Tests for failed cases should reference specific error ID, not DASH header

A. Should have a utility to break apart means for merged dimensions. For example,
area weighted means of a 2D tripolar grid

1. positive integers is weird
4. link to other pages in examples markdown
    - gridfile.expand with gridfile.addDimension (in examples)
    - gridMetadata.edit with gridMetadata.editAttributes

7. dataSourceFailed error in gridfile.load
    - ??? This may be complete
8. Misc sections, both for classes and functions
   -Options to include graphics
   -
9. Remove "throws" from non-assert calls
    -Or treat throws in a more consistent way through the docs

Add properties parsing to class file autodoc

sv.uncouple(0) to uncouple all variables?
Review string.indexedDimension

STATE VECTOR
1. Verbosity toggle
2. Constructor documentation
    - Add link once "label" method is complete
    - Add verbosity details

Should svv Methods that issue errors should have default headers?
(And should gridfile?)


Write tests
Write examples

Link to ensembleMetadata.append? in addMembers doc of meta output



FINISH GRIDFILE:

Minimize error stacks in gridfile methods
-gridfileSources.indices
-methods that call gridMetadata.assertUnique

Combine dash.gridfileSources.indices with dash.parse.stringsOrIndices

Consider renaming absolutePaths to preferredPath and adding switches syntax

Update gridfile examples to show new disp

Write buildTestdata methods

Write examples
    gridfile