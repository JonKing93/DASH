Welcome to the DASH Docs!
=========================

**DASH** is a Matlab toolbox that implements paleoclimate data assimilation. The toolbox is not designed around any particular assimilation or reconstruction. Rather, DASH provides tools that implement common tasks for paleoclimate DA workflows. The toolbox is intended for use from both the console, and within scripts/functions.


Getting Started
---------------
If you have not installed the toolbox, you can find installation instructions here: :doc:`Installing DASH <installation>`

If you are new to DASH, we **strongly** recommend checking out the :doc:`DASH Tutorial <Tutorial/welcome>`. The tutorial introduces each component of DASH step-by-step, and includes several demo datasets for practicing using DASH commands. We recommend setting aside several hours to complete the tutorial.


Accessing the docs
------------------
You can use the ``dash.doc`` command to load these docs at any time. After :doc:`installing DASH <installation>`, enter ``dash.doc`` in the Matlab console to open the documentation to this page.

To open the documentation for a specific item in the DASH toolbox, enter ``dash.doc('<item name>')``. For example, ``dash.doc('kalmanFilter')`` will open the documentation for the Kalman filter class, and ``dash.doc('kalmanFilter.run')`` will open the documentation for the ``kalmanFilter.run`` method.

Alternatively, you can use the Matlab help browser to access the  documentation for an item by entering ``help <item name>`` in the Matlab console, and then clicking on the ``Documentation Page`` link at the bottom of the help text.


Reference Guide
---------------
This documentation includes a complete reference guide to the DASH toolbox. This reference guide includes usage information for every class, package, function, and method in the DASH toolbox. If you like, you can learn about the toolbox by reading through the reference guide (but we **strongly** recommend :doc:`the tutorial <Tutorial/welcome>` for first-time users).

This list describes the major components of DASH in a suggested reading order:

:doc:`gridMetadata <gridMetadata>`
    Helps define human-readable metadata to describe climate datasets.

:doc:`gridfile <gridfile>`
    Catalogues climate data sets and provides a common interface for accessing data stored in diverse formats.

:doc:`stateVector <stateVector>`
    Design and build state vector ensembles.

:doc:`ensemble <ensemble>`
    Manipulate state vector ensembles in a memory-efficient manner. Also includes tools for designing evolving ensembles.

:doc:`ensembleMetadata <ensembleMetadata>`
    Locate specific data elements within a state vector ensemble. Also includes tools for regridding variables from a state vector.

:doc:`PSM <PSM>`
    Implement external proxy system modeling codes.

:doc:`kalmanFilter <kalmanFilter>`
    Implement ensemble Kalman filter algorithms.

:doc:`particleFilter <particleFilter>`
    Implement particle filter algorithms.

:doc:`optimalSensor <optimalSensor>`
    Implement optimal sensor algorithms.

:doc:`dash <dash>`
    A collection of utilities that help the toolbox run. Users may be interested in the ``dash.localize`` and ``dash.closest`` subpackages.
