---
sections:
  - BaySPAR
  - Prerequisites
  - Initialize
  - row | | 2
  - lat | | 2
  - lon | | 2
  - options | | 2
  - Run directly
---

# BaySPAR

Use the baysparPSM class to create PSMs that implement BaySPAR, a Bayesian forward model for TEX<sub>86</sub>. Find [BaySPAR on Github](https://github.com/jesstierney/BAYSPAR), or see the paper:

Tierney, J.E. & Tingley, M.P. (2014) A Bayesian, spatially-varying calibration model for the TEX86 proxy. Geochimica et Cosmochimica Acta, 127, 83-106. [https://doi.org/10.1016/j.gca.2013.11.026](https://doi.org/10.1016/j.gca.2013.11.026).

### Prerequisites

Download the [BAYSPAR repository](https://github.com/jesstierney/BAYSPAR) and add it to the Matlab active path. If you have git installed you can use:
```matlab
PSM.download('bayspar');
```
to do this automatically.

The BaySPAR package also requires the [MATLAB curve fitting toolbox](https://www.mathworks.com/products/curvefitting.html). If you do not have this toolbox, you will need to [add it to your release](https://www.mathworks.com/downloads/web_downloads/select_release?mode=gwylf).

### Initialize
To create a new baysparPSM object, use:
```matlab
mypsm = baysparPSM(row, lat, lon, options);
```
The inputs are as follows:

##### row
An array that indicates the state vector rows with the sea surface temperatures (in Celsius) required to run the PSM. The array should have a single row.

##### lat
A scalar indicating the latitude of the proxy site.

##### lon
A scalar indicating the longitude of the proxy site.

##### options
An optional input to specify additional parameters for the Bayesian model. A cell vector with up to three elements. To use the default options, either do not specify the option or use an empty array as input.

1. Element 1: A string specifying the calibration. If unspecified, uses the sea-surface temperature calibration. Options are:
* <code><span style="color:#cc00cc;font-size:0.875em">"SST"</span></code>: Sea-surface temperature calibration
* <code><span style="color:#cc00cc;font-size:0.875em">"subT"</span></code>: A calibration based on a gamma weighted average of temperatures from 0-200 meters.

2. Element 2: A string specifying the calibration mode. If unspecified, uses the standard mode. Options are:
* <code><span style="color:#cc00cc;font-size:0.875em">"standard"</span></code>: The standard mode. Best of Late Quaternary applications
* <code><span style="color:#cc00cc;font-size:0.875em">"analog"</span></code>: The analogue mode. Best for deep time applications

3. Element 3: Required for the analogue mode. A scalar specifying the tolerance in temperature units.

### Run Directly
You can run the BaySPAR forward model directly using "baysparPSM.run". Here, the syntax is:
```matlab
tex86 = baysparPSM.run( lat, lon, SSTs, options );
```
Here, SSTs is a vector of sea-surface temperatures (in Celsius), and the remaining inputs are as described above.
