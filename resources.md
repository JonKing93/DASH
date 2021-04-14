# Resources
Here you can find additional resources for implementing paleoclimate data assimilation

### Climate model output

The [Earth System Grid Federation](https://esgf-node.llnl.gov/projects/esgf-llnl/) maintains an archive of climate model output from the CMIP5 and CMIP6 experiments, which may be useful for building state vector ensembles.

Additionally, the National Center for Atmospheric Research maintains an [archive of model output](https://www.earthsystemgrid.org/) from the CESM and CCSM4 models, including experiments not found in CMIPs 5 or 6.


### Climate proxy archives

NOAA maintains a [collection of paleoclimate proxy data](https://www.ncdc.noaa.gov/data-access/paleoclimatology-data) covering many different proxies, spatial regions, and eras.

The [Pages2k project](http://www.pastglobalchanges.org/products/highlights/10535-2k-temp-database-sci-data-17) is a global collection of proxies spanning the last two millennia, and forms a common starting point for Common Era assimilations.

The [International Tree Ring Data Bank](https://www.ncdc.noaa.gov/data-access/paleoclimatology-data/datasets/tree-ring) is a global compilation of tree ring records and chronologies.


### Proxy system models

The [PSM Tutorial](docs/tutorials/psm/download) includes downloads and links to various proxy system models. These include:

* Bayesian models for planktic foraminifera ([BayFOX](https://github.com/jesstierney/bayfoxm), [BayMAG](https://github.com/jesstierney/BAYMAG), [BaySPAR](https://github.com/jesstierney/BAYSPAR), [BAYSPLINE](https://github.com/jesstierney/BAYSPLINE))
* δ<sup>18</sup>O forward models for multiple proxies via the [PRYSM Python package](https://github.com/sylvia-dee/PRYSM), and
* the [VS-Lite](https://github.com/suztolwinskiward/VSLite) thresholding model of tree ring growth
