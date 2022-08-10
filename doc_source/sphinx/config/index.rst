Welcome to the DASH Docs!
=========================

**DASH** is a Matlab toolbox that implements paleoclimate data assimilation.

These docs are a reference guide for the toolbox. The docs contain usage information for every class, function, package, and method in the toolbox. The major components of the toolbox are as follows:

| :doc:`gridMetadata <gridMetadata>`  - Helps define human-readable metadata to describe climate datasets
| :doc:`gridfile <gridfile>`  - Catalogues data sets and provides a common interface for accessing data stored in diverse formats
| :doc:`stateVector <stateVector>`  - Helps users to design and build state vector ensembles from data stored in gridfile catalogues
| :doc:`ensemble <ensemble>`  - Manipulate saved state vector ensembles in a memory-efficient manner
| :doc:`ensembleMetadata <ensembleMetadata>` - Locate specific data elements within a state vector ensemble
| :doc:`PSM <PSM>` - Facilitate and implement proxy system forward models
| :doc:`kalmanFilter <kalmanFilter>` - Implement offline ensemble Kalman filter algorithms
| :doc:`particleFilter <particleFilter>` - Implement offline ensemble particle filter algorithms
| :doc:`optimalSensor <optimalSensor>` - Implement optimal sensor algorithms
| :doc:`dash <dash>` - A collection of utilites that help the toolbox run.

You can learn about any of these components by clicking their links here, or by using the sidebar to navigate through the documentation. 

Accessing the docs
------------------

You can use the dash.doc command to access this documentation at any time. Enter

::

    dash.doc

in the Matlab console to open the documentation to this page. To open the documentation for a specific item in the DASH toolbox, enter:

::

    doc.dash("<item name>")

in the Matlab console. For example:

::

    doc.dash("gridfile")

will open the documentation page for the gridfile class, and

::

    doc.dash("stateVector.build")

will open the documentation page for the stateVector.build method.

Alternatively, you can use the Matlab help browser to access the documentation for an item by entering:

::

    help <item name>

in the console, and then clicking the "Documentation Page" link at the bottom of the help text.




.. toctree::
    :caption: Reference
    :hidden:

    gridMetadata
    gridfile
    stateVector
    ensemble
    ensembleMetadata
    PSM
    kalmanFilter
    particleFilter
    optimalSensor
    dash
