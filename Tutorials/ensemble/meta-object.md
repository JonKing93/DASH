---
layout: simple_layout
title: ensembleMetadata
---

# The ensembleMetadata class

Once you have generated a stateVector ensemble, it's often useful to retrieve various types of metadata about it. Useful summary information can include the variables in the ensemble and their size. You may also want to retrieve metadata down the state vector or across the ensemble. Metadata down the state vector can be used for a variety of tasks, such as selecting the inputs for proxy system models or designing a covariance localization scheme. Metadata across the ensemble can be used to select subsets of ensemble members for use in different assimilations. For example, you may want to systematically assimilate different ensemble members for a study using an evolving prior. The ensembleMetadata class is designed to facilitate all of these tasks.

# ensembleMetadata objects

There are several ways to obtain an ensembleMetadata object for a particular state vector ensemble. When you use the "stateVector.build" method, an ensembleMetadata object for the newly built ensemble is provided as the second output:
```matlab
[~, ensMeta] = sv.build(100);
```
Throughout this tutorial, I will use "ensMeta" to refer to an ensemble metadata object. However, feel free to use a different name in your own code. Likewise, note the use of "sv" to denote a stateVector object.

If you would like to examine the metadata for a state vector *before* building an ensemble, you can also call "ensembleMetadata" directly on a stateVector object.
```matlab
ensMeta = ensembleMetadata(sv);
```

### Other options (uncommon)
 You may recall that "stateVector.build" provides a stateVector object with information about the ensemble as the third output, and this stateVector can be used to add more members to an ensemble. (See [hereFIX THIS]() for a refresher.) You can also call "ensembleMetadata" directly on this object to examine metadata for both the state vector and the ensemble, as per:
 ```matlab
 [~, ~, sv] = sv.build(100);
 sv = sv.add(5);
 ensMeta = ensembleMetadata(sv)
 ```

 Note that for:
 ```matlab
 [~, ensMeta1, sv] = sv.build(100);
 ensMeta2 = ensembleMetadata(sv);
 ```
 ensMeta1 and ensMeta2 are equivalent. So the:
 ```matlab
 [~, ensMeta] = sv.build(100);
 ```
 syntax is recommended when retrieving metadata for an ensemble generated exclusively via "stateVector.build".

 [Previous](welcome)---[Next](sizes)
