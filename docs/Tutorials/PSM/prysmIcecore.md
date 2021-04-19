---
sections:
  - PRYSM Ice Core
  - Prerequisites
  - Initialize
  - rows | | 2
  - altitudeDifference | | 2
  - Run directly
---

# PRYSM Ice Core
Use the "prysmIcecore" class to create PSMs that implement the PRYSM forward model for δ<sup>18</sup>O of ice. [Find PRYSM on Github](https://github.com/sylvia-dee/PRYSM), or see the paper:

Dee, S., Emile‐Geay, J., Evans, M. N., Allam, A., Steig, E. J., & Thompson, D. M. (2015). PRYSM: An open‐source framework for PRoxY System Modeling, with applications to oxygen‐isotope systems. Journal of Advances in Modeling Earth Systems, 7(3), 1220-1247. [https://doi.org/10.1002/2015MS000447](https://doi.org/10.1002/2015MS000447).

### Prerequisites

You will need to [download and install the PRSYM package for Python](prysm-setup) to use this forward model.

### Initialize
Create a new prysmIcecore object using the
"prysmIcecore" command. The syntax is:
```matlab
mypsm = prysmIcecore(row, altitudeDifference)
```
Inputs are as follows:

##### rows
An array that indicates the state vector elements with the δ<sup>18</sup>O (precipitation) values needed to run the PSM. This array should have one row.

##### altitudeDifference

An optional input indicating the distance of the actual altitude above the model altitude (in meters). Should be a numeric scalar.

### Run Directly
You can run the PRYSM ice core forward model directly using "prysmIcecore.run". Here, the syntax is:
```matlab
d18O = prysmIcecore.run(d18Op, altitudeDifference);
```
where d18Op is a vector of δ<sup>18</sup>O values of precipitation, and altitudeDifference is as described above.
