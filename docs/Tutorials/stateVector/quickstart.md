---
layout: simple_layout
title: stateVector Quickstart
---

# Welcome to the stateVector quickstart!

This provides a brief overview of stateVector workflow. If you're looking for something more in depth, check out the step by step [tutorial](welcome).

If you'd like to use the quickstart offline or from the Matlab console, you can download it <a href="quickstart.m" download>here</a> or from the [tutorials branch](https://github.com/JonKing93/DASH/tree/Tutorials) on Github.


#### Create new state vector
```matlab
sv = stateVector('my vector');
```
<br>
#### Add a variable
```matlab
sv = sv.add("T", 'my-temperature-data.grid');
```
<br>
#### Design dimensions
```matlab
grid = gridfile('my-temperature-data.grid');
meta = grid.metadata;
june = month(meta.time==6);
run2 = meta.run==2;
NH = meta.lat>0;

dims = ["lat","time","run"];
type = ["state","ensemble","ensemble"];
indices = {NH, june, run2};
sv = sv.design('T', dims, type, indices);
```
<br>
#### Use a sequence
```matlab
indices = [0 1 2];
metadata = ["June";"July";"August"];
sv = sv.sequence("T", "time", indices, metadata);
```
<br>
#### Take a mean
```matlab
sv = sv.mean('T', 'lat');
sv = sv.mean('T', 'time', [0 1 2]);
```
<br>
#### Take a weighted mean
```matlab
weights = cosd( meta.lat(NH) );
sv = sv.weightedMean('T', 'lat', weights);
```
<br>
#### Build an ensemble
```matlab
X = sv.buildEnsemble(150);
```
