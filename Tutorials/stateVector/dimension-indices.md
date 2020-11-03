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
If I only want to include the Northern Hemisphere in my state vector, then I will want to use elements 92 through 181 along the "lat" dimension. I could use something like:
```matlab
nh = lat > 0;
```
to get dimension indices for latitude.

As a second example, say that the "time" metadata is for the years:
```matlab
time = 850:200;
```
If I only want to use preindustrial years before 1850 in an ensemble, then I will want to use elements 1 through 1000 along the "time" dimension. I could use something like:
```matlab
preindustrial = time < 1850;
```
to get dimension indices for latitude.

As we will see later in the tutorial, you can set the indices for a dimension using the [design method](design).

# Example workflow
You can use gridfile metadata to easily obtain dimension indices. As detailed in the gridfile tutorial, you can obtain a .grid file's metadata via:
```matlab
grid = gridfile('myfile.grid');
meta = grid.metadata;
```

From here, you can easily obtain state and reference indices. For example:
```matlab
% Northern Hemisphere
NH_indices = meta.lat > 0;

% January of every year
Jan_indices = month(meta.time) == 1;

% Ensemble members 2-5
Run_indices = ismember(meta.run, [2:5]);
```

# State indices

We will often classify dimension indices based on whether the corresponding dimension is a state dimension or an ensemble dimension. If a dimension is a state dimension, then its dimension indices are "state indices". State indices are relatively straightforward: they indicate which elements along a dimension to include in a state vector.

# Reference indices

By contrast, if a dimension is an ensemble dimension, then its dimension indices are referred to as "reference indices". Reference indices specify which elements along a dimension ***can*** be used as ensemble members. For example, let's say that time is an ensemble dimension and that it consists of monthly data from 850 to 2005.
```matlab
time = datetime(850,1,15) : calmonths(1) : datetime(2005,12,15);
```

Now let's say that I want ensemble members to be selected from time points in the month of June. Then I could use:
```matlab
june = month(time)==6;
```
to select reference indices for the time dimension. These reference indices point to the 1156 June months along the time dimension.

INSERT FIGURE

These reference points are then the possible ensemble members for a state vector ensemble. In this example, ensemble members could be selected from the following 1156 time points:

INSERT FIGURE

Note that the number of reference points will always be greater than or equal to the number of ensemble members. Continuing the example, if I build a 5 member ensemble, then only 5 of the 1156 reference indices will be used to create ensemble members. The resulting ensemble might look like this:

INSERT FIGURE

but it could also look like this

INSERT FIGURE


# Mean Indices

Taking a mean over a state dimension is relatively straightforward because the mean can be applied over all the state indices. However, taking a mean over an ensemble dimension is more complex. Let's return to the previous example using June months as reference indices. Say we want the state vector to use a mean over the summer months June, July and August (JJA) as opposed to just June. In this case the state vector would look like

INSERT FIGURE

How should we accomplish this? We want to use more months in the state vector ensemble, but setting the reference indices to June, July, and August via something like
```matlab
jja = ismember( month(time), [6 7 8] );
```
would cause ensemble members to be selected from June, July, ***or*** August

INSERT FIGURE

which is not what we want.

Instead, we will use mean indices to take a mean over an ensemble dimension. Mean indices are a vector of elements that indicate which data indices along an ensemble dimension should be used in a mean. Each element indicates the offset from the reference indices. Returning to the example, each reference index points to a June month in a particular year.

INSERT FIGURE: YEAR X

If that year is selected for an ensemble member, then we will want to take a mean at the reference June month (+0 months), the following July month (+1 months), and the subsequent August (+2 months). Consequently, the mean indices will be
```matlab
meanIndices = [0 1 2]
```

The state vector will be constructed by taking a mean over the following months

INSERT FIGURE

resulting in a state vector ensemble like:

INSERT FIGURE

As we will see later in the tutorial, you can set mean indices using the [mean](mean) or [weighted mean](weighted-mean) methods.


# Sequence Indices

As an alternative to a mean over JJA, we might instead want to use a sequence of June, July, and August. In this case, the state vector would look like:

INSERT FIGURE

We will use sequence indices to accomplish this. The syntax for sequence indices is similar to mean indices. Sequence indices are a vector of elements that indicate which data indices along an ensemble dimension should be stacked into a sequence down the state vector. Each element indicates the offset from the reference indices.

In my example, the reference indices point to the June months and we want a sequence of June (+0 months), July (+1), and August (+2), so the sequence indices are

```matlab
seqIndices = [0 1 2];
```
The sequence will be constructed by stacking the following months down the state vector

INSERT FIGURE

and the final state vector ensemble will look something like:

INSERT FIGURE

We will refer to the data elements at the sequence offsets as "sequence elements". In this example, the sequence elements are June, July, and August, and we would say the sequence has 3 elements.

As we will see, you can use the [sequence method](sequence) to set sequence indices.

# Combining mean and sequence indices

In some cases, you may want to stack a sequence of time-means down a state vector. For example, let's say I want my state vector to include a moving three month mean. Specifically, I want the state vector to include a June-July-August (JJA) mean, a July-August-September (JAS), an August-September-October mean (ASO), and a September-October-November mean (SON). This way, the state vector will look like:

INSERT FIGURE

To do this, we will need to use both mean and sequence indices. When DASH builds an ensemble member it uses the following protocol:
1. Select a reference index.
2. Apply sequence indices to the reference index to get the sequence elements.
3. Apply mean indices/offsets to each ***sequence elements*** (not reference index).

In my example, each reference index points at June. I want a mean that starts in June (+0 months), a mean that starts in July (+1), a mean starting in August (+2), and a mean starting in September (+3), so the sequence indices are
```matlab
seqIndices = [0 1 2 3];
```

So, the sequence elements are June, July, August, and September. Next, I want to take a series of three month means. Each mean starts with a sequence element (+0) and includes the following two months (+1 and +2). So the mean indices are
```matlab
meanIndices = [0 1 2];
```

The state vector for each ensemble members will be constructed in the following manner:

INSERT FIGURE

and the final state vector ensemble will look something like:

INSERT FIGURE


Whew, that was a lot of background. Fortunately, that's all you need to know to design state vector templates. So let's start making a state vector!

[Previous](concepts)---[Next](new)
