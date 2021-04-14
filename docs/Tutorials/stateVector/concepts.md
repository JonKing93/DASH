---
sections:
  - Overview
  - State vectors
  - Ensembles
  - State and ensemble dimensions
  - Sequences
---

# Overview

The stateVector class helps design and build a state vector ensemble from data catalogued in .grid files. This takes place in two phases. Phase 1 is the design phase: in this stage you will add variables to a state vector and design them to follow whatever specifications you require. Phase 2 is the build phase: here, the design is finalized and a state vector ensemble is constructed from the design template.

Note that data is not loaded and processed until the end of the build phase. The stateVector class is written to help you design the template for a state vector, which lets you build a state vector ensemble without needing to manipulate large data arrays. Let's review some concepts that will help us to design state vector templates.

# State Vectors

A fundamental concept in ensemble data assimilation is the state vector. In brief, a state vector is a collection of state variables and parameters describing the climate. As a rule of thumb, the elements of a state vector are the climate variables and parameters you are interested in reconstructing. These values are often generated by a climate model, but can also include data from other sources. For example, some paleoclimate assimilation have used state vectors that include real-world proxy records (for the purpose of reconstruction verification). Whatever the application, a state vector can include multiple variables with different spatial and temporal resolutions. For example, I could make a state vector consisting of monthly gridded surface temperatures and precipitation, and annual-mean, spatial-mean temperature in the Northern Hemisphere.

<img src="\DASH\assets\images\stateVector\state-vector.svg" alt="An example state vector." style="width:80%;display:block">
Figure 1: An example state vector.

In my example state vector, there are 3 variables:
1. T - Gridded monthly temperature
2. Tmean - Annual, global mean temperature
3. P - Gridded monthly precipitation


# Ensembles

A second important concept is the state vector ensemble. This is a collection of multiple iterations of a state vector, and is typically used to estimate climate system covariance and as the prior for an assimilation. In paleoclimate, ensemble members (different iterations of the state vector) are typically selected from different time slices and/or ensemble members of climate model output. Continuing the previous example, a small ensemble for my state vector might look like:

<img src="\DASH\assets\images\stateVector\ensemble.svg" alt="An example state vector ensemble." style="width:80%;display:block">
Figure 2: An example state vector ensemble (N=5).

Here, each column is a different ensemble member. Each ensemble member has the T, P, and Tmean variables, but in a different time slice. In the case of ensemble member 5, the ensemble member is from the same time step as ensemble member 1, but in a different simulation.


# State and Ensemble Dimensions

Throughout the stateVector tutorial, we will refer to "state dimensions" and "ensemble dimensions". These dimensions are the different dimensions of a variable (such as latitude, longitude, time, etc). The state or ensemble modifier indicates whether the metadata for the dimension is defined along the state vector or along the ensemble members. If the metadata for a dimension is constant along a row of an ensemble, then it is a state dimension. If the dimension's metadata is constant along a column of the ensemble, then it is an ensemble dimension. Let's zoom in on the "T" variable from my ensemble as an example.

<img src="\DASH\assets\images\stateVector\state-dimensions.svg" alt="State dimensions in a state vector ensemble." style="width:80%;display:block">
Figure 3: State dimensions in a state vector ensemble.

Here, we can see that each row is associated with a unique spatial coordinate because each element in the state vector holds the data for a particular grid point. The latitude-longitude coordinate within each row is constant; for example, row 5 always describes the grid point at (X, Y) regardless of which ensemble member is selected. Thus, latitude and longitude are state dimensions.

By contrast, each column is associated with a constant time and run coordinate.
<img src="\DASH\assets\images\stateVector\ensemble-dimensions.svg" alt="Ensemble dimensions in a state vector ensemble." style="width:80%;display:block">
Figure 4: Ensemble dimensions in a state vector ensemble.

For example, column 5 always refers to data from year 1 in run 2, regardless of the spatial point. Thus, time and run are ensemble dimensions in this case. As a rule of thumb, the "lat","lon","coord","lev", and "var" dimensions are often state dimensions, and the "time" and "run" dimensions are often ensemble dimensions. However, this is just a rule of thumb and not a strict requirement; depending on the application, any dimension could be a state dimension or ensemble dimension.


# Sequences

Sometimes, you may want an ensemble dimension to have some structure along the state vector, which this tutorial will refer to as a "sequence". Sequences most commonly occur when including multiple, sequential time steps in a state vector.

For example, let's say I want my "T" variable to include the spatial grid from June, July, and August in a given year. The state vector ensemble for this variable would have the following structure.

<img src="\DASH\assets\images\stateVector\sequence.svg" alt="An example of a sequence." style="width:80%;display:block">
Figure 5: An example of a sequence for the time dimension.

We can see that the ensemble dimension "time" now has metadata along both the state vector and the ensemble. The columns still refer to a unique (time, run) coordinate, but the rows also refer to a particular month. This additional metadata along the state vector forms a sequence for the time dimension. If you like alliteration, you can use "sequences are stacking" to remember that a sequence typically stacks multiple time points down a state vector. Note that time is still an ensemble dimension because metadata along the ensemble is still required to form a unique time coordinate. For example, we know an element in row 1 is from June, but we don't know the year until referencing a specific ensemble member.