TODO:

Fix Python installation for PRYSM forward models

Add notice of how to access help to help DASH and help dash

Write readme and getting started markdowns

0. Tests for failed cases should reference specific error ID, not just DASH header

A. Should have a utility to break apart means for merged dimensions. For example,
area weighted means of a 2D tripolar grid

B. ensembleMetadata.appendMembers?
When calling sv.addMembers - how to treat returned metadata?

4. link to other pages in examples markdown
    - gridfile.expand with gridfile.addDimension (in examples)
    - gridMetadata.edit with gridMetadata.editAttributes


8. Misc sections, both for classes and functions
   -Options to include graphics in HTML doc
   
9. Remove "throws" from non-assert calls
    -Or treat throws in a more consistent way through the docs

10. Add properties parsing to class file autodoc


STATE VECTOR

Write tests

Link to ensembleMetadata.append? in addMembers doc of meta output

Add strong tags to function headers


FINISH GRIDFILE:

Write buildTestdata methods


AFTER NEXT RELEASE

Static PSM.run to implement forward model with any parameters
More detailed documentation of PSM inputs
(Low priority) Error check PSM parameters
PSM.estimate that shares loaded data among PSMs
    - Might not be necessary as most PSMs probably do not share data
    - Then again, might be nice to use a single load operation

ensemble.addMembers
Write examples for user facing methods
Write examples for internal methods (lower priority)
Add progress bars to long methods
Add links to scalar disp for array objects (click on a gridfile in an array disp to show the disp for the scalar gridfile/ensemble/sv/etc)
Add handling for <missing> strings
Add serializer to ensembleMetadata (maybe do now)
Scalar return values don't require scalarObjs (for example, returning a label)

Utility to convert MAT files to v7.3

Add PSMs to optimal sensor

Kalman filter localize, blend, and setCovariance could allow NaN values for sites that don't occur in the same time steps
    - could generalize the ensembleFilter.assertValidR method
Method to calculate calibration ratio without updating ensemble

Could write an optimized KF.run for the case when the covariance is set and there are multiple priors.
    - In this case, the Kalman gain calculations are likely more expensive than prior decompositions,
    - so might want to iterate over covariance first, priors second.