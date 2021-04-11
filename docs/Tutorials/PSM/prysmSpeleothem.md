---
sections:
  - PRYSM Speleothem
  - Prerequisites
  - Initialize
  - Run directly
---

# PRYSM Speleothem
Use the "prysmSpeleothem" class to create PSMs that implement the PRYSM forward model for δ<sup>18</sup>O of speleothem calcite / dripwater. [Find PRYSM on Github](https://github.com/sylvia-dee/PRYSM), or see the paper:

Dee, S., Emile‐Geay, J., Evans, M. N., Allam, A., Steig, E. J., & Thompson, D. M. (2015). PRYSM: An open‐source framework for PRoxY System Modeling, with applications to oxygen‐isotope systems. Journal of Advances in Modeling Earth Systems, 7(3), 1220-1247. [https://doi.org/10.1002/2015MS000447](https://doi.org/10.1002/2015MS000447).

### Prerequisites

You will need to [download and install the PRSYM package for Python](prysm-setup) to use this forward model.

### Initialize
Create a new prysmSpeleothem object using the
"prysmSpeleothem" command. The syntax is:
```matlab
mypsm = prysmSpeleothem( rows, timeStep, model, tau0, Pe )
```
Inputs are as follows:

##### rows
An array that indicates the state vector elements needed to run the PSM. This array should have two rows: the first row should indicate δ<sup>18</sup>O of precipitation or soil water (in permil), the second row should indicate mean annual temperature (in Kelvin).

##### timeStep
An optional input indicating the time step (in years). A scalar. By default, uses a monthly timestep.

##### model
An optional input specifying the aquifer-recharge model. A string. Options are:
* "Well-Mixed": Assuming a well-mixed aquifer
* "Adv-Disp": Uses an advective-dispersion model

By default, uses the well-mixed model.

##### tau0
An optional input specifying the mean transit time (in years). A scalar. The default is 0.5.

##### Pe
An optional input specifying the Peclet number. A scalar. The default is 1.

### Run Directly
You can run the PRYSM speleothem forward model directly using prysmSpeleothem.run". Here, the syntax is:
```matlab
d18O = prysmSpeleothem( d18Op, T, timeStep, model, tau0, Pe )
```
where d18Op is a vector of δ<sup>18</sup>O values of precipitation or soil water (in permil), and T is a vector of mean annual temperatures (in Kelvin).
