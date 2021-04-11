---
sections:
  - BayMAG
  - Prerequisites
  - Initialize
  - Run directly
---

# BayMAG

Use the baymagPSM class to create PSMs that implement BayMAG, a Bayesian forward model for Mg/Ca ratios of planktic foraminifera. Find [BayMAG on Github](https://github.com/jesstierney/BAYMAG),  or see the paper:

Tierney, J. E., Malevich, S. B., Gray, W., Vetter, L., & Thirumalai, K. (2019). Bayesian calibration of the Mg/Ca paleothermometer in planktic foraminifera. Paleoceanography and Paleoclimatology, 34(12), 2005-2030. [https://doi.org/10.1029/2019PA003744](https://doi.org/10.1029/2019PA003744).

### Prerequisites

Download the [BAYMAG repository](https://github.com/jesstierney/BAYMAG) and add it to the Matlab active path. If you have git installed, you can use:
```matlab
PSM.download('baymag');
```
to do this automatically.

The BayMAG package also requires the [MATLAB curve fitting toolbox](https://www.mathworks.com/products/curvefitting.html). If you do not have this toolbox, you will need to [add it to your release](https://www.mathworks.com/downloads/web_downloads/select_release?mode=gwylf).

### Initialize
To create a new baymagPSM object, use:
```matlab
mypsm = baymagPSM(row, age, omega, salinity, pH, clean, species, options)
```
The inputs are as follows:

##### row
An array that indicates the state vector rows with the sea surface temperatures (in Celsius) required to run the PSM. This array should have a single row.

##### age
A scalar or vector of ages. Use units of Ma if applying a seawater correction, otherwise any units work.

##### omega
A scalar or vector of bottom water saturation states.

##### salinity
A scalar or vector of salinity values in units of psu.

##### pH
A scalar or vector of pH values (using the total scale). Use a dummy value if using a species not sensitive to pH.

##### clean
A scalar indicating the cleaning technique. Options are:
* 1: Reductive
* 0: Oxidative
* Values between 0 and 1: A mix of oxidative and reductive cleaning

##### species
A string indicating the target species. Options are:
* <code><span style="color:#cc00cc;font-size:0.875em">"ruber"</span></code>: G. Ruber (white or pink)
* <code><span style="color:#cc00cc;font-size:0.875em">"bulloides"</span></code>: G. Bulloides
* <code><span style="color:#cc00cc;font-size:0.875em">"sacculifer"</span></code>: T. Sacculifer
* <code><span style="color:#cc00cc;font-size:0.875em">"pachy"</span></code>: N. Pachyderma
* <code><span style="color:#cc00cc;font-size:0.875em">"all"</span></code>: Pooled calibration model for annual SST
* <code><span style="color:#cc00cc;font-size:0.875em">"all_sea"</span></code>: Pooled calibration model for seasonal SST

##### options
An optional input to specify additional parameters for the Bayesian model. A cell vector with up to four elements. To use the default values, either do not specify the option or use an empty array as input.

1. Element 1: A scalar indicating whether to a apply a correction for changes to Mg/Ca of seawater. If unspecified, does not apply a seawater correction. Options are:
* 1: Apply a seawater correction
* 0: Do not apply a seawater correction

2. Element 2: A scalar indicating a prior mean. Must use units of mmol/mol.

3. Element 3: A scalar indicating a prior standard deviation. Must use units of mmol/mol.

4. Element 4: A selection of Bayesian parameters. A string vector with three elements, each indicating a parameters filename.

### Run Directly
You can run a baymagPSM directly on data values using "baymagPSM.run". Here, the syntax is:
```matlab
mgca = baymagPSM.run( age, SSTs, omega, salinity, pH, clean, species, options );
```
Here, SSTs is a vector of sea-surface temperatures (in Celsius), and the remaining inputs are as described above.
