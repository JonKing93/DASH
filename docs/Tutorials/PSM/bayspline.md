---
sections:
  - BaySPLINE
  - Prerequisites
  - Initialize
  - Run directly
---

# BaySPLINE

Use the baysplinePSM class to create PSMs that implement BaySPLINE, a Bayesian forward model for U<sup>K'</sup><sub>37</sub>. Find [BaySPLINE on Github](https://github.com/jesstierney/BAYSPLINE), or see the paper:

Tierney, J.E. & Tingley, M.P. (2018) BAYSPLINE: A New Calibration for the Alkenone Paleothermometer. Paleoceanography and Paleoclimatology 33, 281-301, [http://doi.org/10.1002/2017PA003201](http://doi.org/10.1002/2017PA003201).

### Prerequisites

Download the [BAYSPLINE repository](https://github.com/jesstierney/BAYSPLINE) and add it to the Matlab active path. If you have git installed, you can use:
```matlab
PSM.download('bayspline');
```
to do this automatically.

The BaySPLINE package also requires the [MATLAB curve fitting toolbox](https://www.mathworks.com/products/curvefitting.html). If you do not have this toolbox, you will need to [add it to your release](https://www.mathworks.com/downloads/web_downloads/select_release?mode=gwylf).

### Initialize
To create a new baysplinePSM object, use:
```matlab
mypsm = baysplinePSM(row);
```

Here, "row" is an array that indicates the state vector rows with the sea surface temperatures (in Celsius) required to run the PSM. The array should have a single row.

### Run Directly

You can run the BaySPLINE forward model directly using "baysplinePSM.run". Here, the syntax is:
```matlab
uk37 = baysplinePSM.run(SSTs)
```
where SSTs is a vector of sea-surface temperatures (in Celsius);
