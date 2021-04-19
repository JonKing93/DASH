---
sections:
  - Overlap
  - Enable or disable overlap
---
# Overlap

When it builds a state vector ensemble, "buildEnsemble" will select ensemble members from different reference indices. This way, there are no repeat ensemble members. However, it is possible for mutliple ensemble members to use the same data, and this is known as overlap.

For example, say that "time" is the ensemble dimension and consists of annually spaced data. Let's say the state vector either uses all indices as reference indices and includes either a sequence of 3 years or a mean over three years. If we build the ensemble naively, then the first ensemble member could use data from years 1, 2 and 3 and the second ensemble member could data from years 2, 3, and 4. But there's a problem here: both ensemble members use data from years 2 and 3, so information is being repeated in the ensemble. Essentially, the sequence/mean indices cause different ensemble members to partially overlap.

This is generally not desired, so this overlap is not allowed by default. Consequently, if you use "buildEnsemble" with the previous example, then ensemble member 1 will use years 1, 2 and 3; ensemble member 2 will use years 4, 5, and 6; and so on.

<br>
### Enable or disable overlap

You can enable overlap for a variable when you first add it to a state vector. (See [here](add#optional-set-overlap-options))

If you would like to enable overlap for your ensemble, use the "allowOverlap" method, provide a list of variable names, and use true as the second input. For example:
```matlab
sv = sv.allowOverlap( ["T","P"], true)
```
will allow overlap for the "T" and "P" variables. If you accidentally enable overlap, you can disable it by setting the second argument to false. For example:
```matlab
sv = sv.allowOverlap( ["T", "P"], false)
```
