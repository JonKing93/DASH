TODO:

0. Tests for failed cases should reference specific error ID, not DASH header

A. Should have a utility to break apart means for merged dimensions. For example,
area weighted means of a 2D tripolar grid

B. ensembleMetadata.appendMembers?
When calling sv.addMembers - how to treat returned metadata?

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


STATE VECTOR

Write tests

Link to ensembleMetadata.append? in addMembers doc of meta output

Add strong tags to function headers


FINISH GRIDFILE:

Write buildTestdata methods


AFTER NEXT RELEASE

Write examples for user facing methods
Write examples for internal methods (lower priority)
Add progress bars to long methods
Add links to scalar disp for array objects (click on a gridfile in an array disp to show the disp for the scalar gridfile/ensemble/sv/etc)
Add handling for <missing> strings
Add serializer to ensembleMetadata (maybe do now)
Scalar return values don't require scalarObjs (for example, returning a label)