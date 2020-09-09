---
layout: simple_layout
title: Dimension Indices
---

# Dimension Indices
As mentioned, the stateVector class builds state vectors from data catalogued in .grid files. However, we  will not always need to use *all* of a .grid file's data in a state vector ensemble; often, a small subset of the data is sufficient. As such, we will need a way to select subsets of .grid file data. In stateVector, we will do this by selecting specific elements along the dimensions of the .grid file's N-dimensional array.

For example, say I have a .grid file that organizes a 4D array that is lat x lon x time x run and that the "lat" metadata is given by:
```matlab
lat = -90:90;
```
If I only want to include the Northern Hemisphere in my state vector, then I will want to use elements 92 through 181 along the "lat" dimension.

# State and Reference Indices

As the name suggests, state indices are the dimension indices for a state dimension. They indicate which elements along a dimension to add to a state vector.

The dimension indices for ensemble dimensions are slightly more complex. We will refer to these as "reference indices" (the reason for this name will become clear later). Reference indices specify which elements along a dimension can be used as ensemble members. For example, say that "time" is an ensemble dimension, and that the time consists of monthly data from 1850 to 2005. If I use reference indices that point to month of June, then all ensemble members will be selected from the month of June.
<img src="\DASH\assets\images\reference-indices.svg" alt="Reference indices pointing at June." style="width:80%;display:block">
<img src="\DASH\assets\images\ref-ensemble.svg" alt="A state vector ensemble with ensemble members selected from Junes." style="width:80%;display:block">
Figure 1: Reference indices for June ensemble members and accompanying state vector ensemble.

# Example workflow
You can use gridfile metadata to easily obtain data indices. As detailed in the gridfile tutorial, you can obtain a .grid file's metadata via:
```matlab
grid = gridfile('myfile.grid');
meta = grid.metadata;
```

From here, you can easily obtain state and reference indices. For example:
```matlab
% Northern Hemisphere
NH_indices = meta.lat > 0;

% January of every year
Jan_indices = year(meta.time) == 1;

% Ensemble members 2-5
Run_indices = ismember(meta.run, [2:5]);
```

# Sequence indices

We use the name "reference indices", because they form the reference point for sequences. Using the same example, let's say that I want each state vector to hold data from June in three successive years. This is a sequence with 3 elements (one element per year). We will need to provide a set of sequence indices, which will indicate how to find these three elements for each ensemble member. Each sequence index specifies how many data indices past the reference index to find the next element in the sequence. For this example, the sequence indices would be:
```matlab
seqIndices = [0, 12, 24];
```
The first sequence index (0), says to use the data at the reference index as the first June. Since the data is monthly, June of the following year is 12 data indices away from this first June, so sequence index 2 is 12. Finally, the third June is 24 months away from the first June, so its sequence index is 24.

<img src="\DASH\assets\images\sequence-indices.svg" alt="Sequence indices pointing at three consecutive Junes." style="width:80%;display:block">
Figure 2: Sequence indices pointing to three consecutive Junes.


# Mean Indices

If we want to take a mean over an ensemble dimension, we will need to provide a set of mean indices, which will indicate how to find elements in the mean for each ensemble member. The syntax here is similar to sequence indices: each mean index specifies how many data indices past the reference index to find the next element in the mean. If my reference indices point to the month of June, then
```matlab
meanIndices = [0, 1, 2];
```
would cause each state vector to hold the mean of data from June, July, and August in each year.
INSERT FIGURE HERE.

If you have both mean and sequence indices, then the mean indices will be applied to *each* sequence element. For example
```matlab
seqIndices = [0, 12, 24];
meanIndices = [0, 1, 2];
```
would create state vectors consisting of the June, July, August summer mean in three consecutive years.

INSERT FIGURE HERE.
