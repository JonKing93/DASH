# PSM Quick Reference
The following page is a quick reference for working with PSMs. Check out the pages of the individual PSMs for details on their implementation.

Name | Class | Rows | Parameters
---- | ----- | ---- | ----------
Linear | [linearPSM](linear) | The climate variables for each slope | slopes, intercept
[BayFOX](https://github.com/jesstierney/bayfoxm) | [bayfoxPSM](bayfox) | 1. SSTs (Celsius), <br>2. δ<sup>18</sup>O<sub>sea-water</sub> (VSMOW) | species
[BayMAG](https://github.com/jesstierney/BAYMAG) | [baymagPSM](baymag) | SSTs (Celsius) | age, omega, salinity, pH, clean, species, options
[BaySPAR](https://github.com/jesstierney/BAYSPAR) | [baysparPSM](bayspar) | SSTs (Celsius) | lat, lon, options
[BaySPLINE](https://github.com/jesstierney/BAYSPLINE) | [baysplinePSM](bayspline) | SSTs (Celsius) |
[PRYSM](https://github.com/sylvia-dee/PRYSM) Cellulose | [prysmCellulose](prysmCellulose) | 1. Temperature (Kelvin) <br> 2. Precipitation (mm/day) <br> 3. Relative Humidity (%) | δ<sup>18</sup>O<sub>s</sub>, δ<sup>18</sup>O<sub>p</sub>, δ<sup>18</sup>O<sub>v</sub>, model, useIsotopes
[PRYSM](https://github.com/sylvia-dee/PRYSM) Coral | [prysmCoral](prysmCoral) | 1. SST anomaly <br> 2. SSS anomaly (psu), or <br> 2. δ<sup>18</sup>O<sub>sea-water</sub> | useSSS, lat, lon, species, bcoeffs
[PRYSM](https://github.com/sylvia-dee/PRYSM) Ice Core | [prysmIcecore](prysmIcecore) | δ<sup>18</sup>O<sub>precipitation</sub> | altitudeDifference
[PRYSM](https://github.com/sylvia-dee/PRYSM) Speleothem | [prysmSpeleothem](prysmSpeleothem) | 1. δ<sup>18</sup>O<sub>precipitation</sub> <br> 2. Temperature (Kelvin) | timeStep, model, tau0, Pe
[VS-Lite](https://github.com/sylvia-dee/PRYSM) | [vslitePSM](vslite) | 1-12: Temperature (C) <br> 13-24: Precipitation (mm) | phi, T1, T2, M1, M2, options 
