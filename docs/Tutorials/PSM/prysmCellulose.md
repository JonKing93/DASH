---
sections:
  - PRYSM Cellulose
  - Prerequisites
  - Initialize
  - Run directly
---

# PRYSM Cellulose
Use the "prysmCellulose" class to create PSMs that implement the PRYSM forward model for δ<sup>18</sup>O of cellulose. [Find PRYSM on Github](https://github.com/sylvia-dee/PRYSM), or see the paper:

Dee, S., Emile‐Geay, J., Evans, M. N., Allam, A., Steig, E. J., & Thompson, D. M. (2015). PRYSM: An open‐source framework for PRoxY System Modeling, with applications to oxygen‐isotope systems. Journal of Advances in Modeling Earth Systems, 7(3), 1220-1247. [https://doi.org/10.1002/2015MS000447](https://doi.org/10.1002/2015MS000447).

### Prerequisites

You will need to [download and install the PRSYM package for Python](prysm-setup) to use this forward model.

### Initialize
Create a new prysmCellulose object using the "prysmCellulose" command. The syntax is:
```matlab
mypsm = prysmCellulose( rows, d18Os, d18Op, d18Ov, model, useIsotopes )
```
The inputs are as follows:

##### rows
An array that indicates the state vector elements needed to run the PSM. This array should have three rows: the first should indicate temperature (in Kelvin), the second should indicate precipitation (in mm/day), and the third should be relative humidity (in %).

##### d18Os
A scalar indicating the δ<sup>18</sup>O ratio of soil water.

##### d18Op
A scalar indicating the δ<sup>18</sup>O ratio of precipitation.

##### d18Ov
A scalar indicating the δ<sup>18</sup>O ratio of ambient vapor at the surface layer.

##### model
A string indicating which cellulose model to use. Options are:
* <code><span style="color:#cc00cc;font-size:0.875em">"Roden"</span></code>: The cellulose model of [Roden et al., 2002](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.1054.9596&rep=rep1&type=pdf)
* <code><span style="color:#cc00cc;font-size:0.875em">"Evans"</span></code>: The cellulose model of [Evans, 2007](https://doi.org/10.1029/2006GC001406)

##### useIsotopes

A scalar logical indicating whether to use isotope enabled model output. Options are:
* true: Use the isotope-enable output
* false: Use precipitation to calculate soil water isotopes and parametrize vapor

### Run Directly
You can run the PRYSM cellulose forward model directly using "prysmCellulose.run". Here, the syntax is:
```matlab
d18O = prsymCellulose( T, P, RH, d18Os, d18Op, d18Ov, model, useIsotopes )
```
where T is a vector of temperatures (in Kelvin), P is a vector of precipitation values (in mm/day), and RH is a vector of relative humidity (in %). The remaining inputs are as described above.
