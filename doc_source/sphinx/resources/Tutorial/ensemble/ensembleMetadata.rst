ensembleMetadata
================
The ``ensembleMetadata`` class organizes and records metadata values along the rows and columns of a state vector ensemble. The class uses this metadata to provide a number of utility functions for working with state vector ensembles. In addition to normal workflows, these utilities can help you extend ``DASH`` to create new routines and analyses.

We'll be seeing ``ensembleMetadata`` commands throughout the rest of the tutorial, and we'll introduce the commands as they become relevant. For now, we'll just give a brief overview of some of the class's capabilities.


Locate forward model inputs
---------------------------
You can use the class to locate the variables needed to run proxy forward models. The ``closestLatLon`` command locates data values nearest to a set of coordinates, and the ``find`` command locates state vector rows corresponding to a specific variable. Also, you can use the ``variable`` command to return metadata values for specific state vector variables.


Coordinates for localization
----------------------------
You can use the ``latlon`` command to return a latitude-longitude coordinate for every state vector element. These coordinates are often useful for implementing covariance localization.



Regrid state vector variables
-----------------------------
You can use the ``regrid`` command to reshape state vector variables into their original data grids. This can be useful for mapping assimilated variables, or for double checking that an ensemble appears correct.



Identify ensemble members
-------------------------
You can use the ``members`` command to return metadata for each ensemble member in the state vector. This can be useful when designing evolving (time-dependent) ensembles.



And more...
-----------
The ``ensembleMetadata`` class has a number of other utilities that we will not discuss here. However, we encourage reading the documentation at ``dash.doc('ensembleMetadata')``. If you plan on writing new routines to manipulate ensembles, then this documentation is a good place to start.
