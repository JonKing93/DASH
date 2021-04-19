# Supported PSMs

In addition to a built-in general linear model, DASH provides support for working with several external proxy system models. In brief, these are:
1. Bay*: A collection of Bayesian forward models for planktic foraminifera,
2. PRYSM: A Python package with δ<sup>18</sup>O forward models for multiple proxies, and
3. VS-Lite: A thresholding model of tree-ring growth.

Follow the links below to find details on working with specific PSMs, or see the [PSM quick reference](reference) page.

### Bay* Foraminiferal Models
The following are Bayesian forward models for planktic foraminifera.
* [BayFOX](bayfox): For δ<sup>18</sup>O<sub>c</sub> values.
* [BayMAG](baymag): For Mg/Ca ratios
* [BaySPAR](bayspar): For TEX<sub>86</sub> measurements
* [BaySPLINE](bayspline): For U<sup>K'</sup><sub>37</sub> values.

### PRYSM
A Python package with δ<sup>18</sup>O forward models for multiple proxies. We recommend reading the instructions for [installing PRYSM for use with DASH](prysm-setup) before using these forward models.
* [Cellulose](prysmCellulose): For δ<sup>18</sup>O of cellulose
* [Coral](prysmCoral): For δ<sup>18</sup>O of coral
* [Icecore](prysmIcecore): Precipitation-weighted δ<sup>18</sup>O of ice
* [Speleothem](prysmSpeleothem): For δ<sup>18</sup>O of cellulose of speleothem calcite and dripwater.

### Misc
Other supported forward models
* [General Linear Model](linear): A general linear forward model, and
* [VS-Lite](vslite): The Vaganov-Shashkin Lite (VS-Lite) thresholding model of tree ring growth.

### Other forward models

You may be interested in using other forward models. If this is the case, you can either
* [estimate proxies *without* PSM.estimate](format-estimates), or
* [create a new PSM class](new-class)
