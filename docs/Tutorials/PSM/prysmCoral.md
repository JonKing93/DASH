---
sections:
  - PRYSM Coral
  - Prerequisites
  - Initialize
  - Run directly
---

# PRYSM Cellulose
Use the "prysmCoral" class to create PSMs that implement the PRYSM forward model for δ<sup>18</sup>O of coral. [Find PRYSM on Github](https://github.com/sylvia-dee/PRYSM), or see the paper:

Dee, S., Emile‐Geay, J., Evans, M. N., Allam, A., Steig, E. J., & Thompson, D. M. (2015). PRYSM: An open‐source framework for PRoxY System Modeling, with applications to oxygen‐isotope systems. Journal of Advances in Modeling Earth Systems, 7(3), 1220-1247. [https://doi.org/10.1002/2015MS000447](https://doi.org/10.1002/2015MS000447).

### Prerequisites

You will need to [download and install the PRSYM package for Python](prysm-setup) to use this forward model.

### Initialize
Create a new prysmCoral object using the "prysmCoral" command. The syntax is:
```matlab
mypsm = prysmCoral( rows, useSSS, lat, lon, species, bcoeffs )
```
The inputs are as follows:

##### rows
An array that indicates the state vector elements needed to run the PSM. This array should have three rows: the first row should indicate sea surface temperature anomalies (in Celsius), the second row should either indicate sea surface salinity anomalies (in psu) or δ<sup>18</sup>O of seawater (in permil).

##### useSSS
A scalar logical indicating whether you are providing sea surface salinity anomalies, or δ<sup>18</sup>O of seawater as the second climate variable. Options are:
* true: Using sea-surface salinity anomalies
* false: Using δ<sup>18</sup>O of seawater

##### lat
A scalar indicating the latitude of the coral site in decimal degrees.

##### lon
A scalar indicating the longitude of the coral site in decimal degrees on the interval [0, 360].

##### species
A string indicating the coral species. This adjusts the slope of the forward model regression. Options are:
* <code><span style="color:#cc00cc;font-size:0.875em">"Default"</span></code>: Use the default regression parameter, a = -0.22
* <code><span style="color:#cc00cc;font-size:0.875em">"Porites_sp"</span></code>: a = -.26178
* <code><span style="color:#cc00cc;font-size:0.875em">"Porites_lob"</span></code>: a = -.19646
* <code><span style="color:#cc00cc;font-size:0.875em">"Porites_lut"</span></code>: a = -.17391
* <code><span style="color:#cc00cc;font-size:0.875em">"Porites_aus"</span></code>: a = -.21
* <code><span style="color:#cc00cc;font-size:0.875em">"Montast"</span></code>: a = -.22124
* <code><span style="color:#cc00cc;font-size:0.875em">"Diploas"</span></code>: a = -.14992

##### bcoeffs
An optional input, used to specify the five regional b coefficients, as defined by [Legrande and Schmidt, 2006](https://doi.org/10.1029/2006GL026011).

A numeric vector with five elements. Elements are the b coefficients for
1. The Red Sea,
2. Tropical Pacific,
3. South Pacific,
4. Indian Ocean, and
5. Tropical Atlantic Ocean / Caribbean

in order. Uses the default coefficient for any elements that are unspecified or NaN.

### Run directly
You can run the PRYSM coral forward model directly using "prysmCoral.run". Here, the syntax is:
```matlab
d18O = prysmCoral(lat, lon, SST, SSS, d18O, species, bcoeffs)
```
where SST is a vector of sea-surface temperature anomalies (in Celsius), and SSS is a vector of sea-surface salinity anomalies (in Celsius). If available, d18O should be a vector of δ<sup>18</sup>O values for seawater (in permil); if not available, use an empty array. The remaining inputs are as described above.
