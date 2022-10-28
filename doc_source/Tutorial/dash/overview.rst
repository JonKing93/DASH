DASH Overview
=============
DASH is a Matlab toolbox written to facilitate paleoclimate data assimilation. The code is designed for use from the command line as well as within scripts and functions. The toolbox is intended for users with some basic experience with MATLAB. In particular, users will benefit from knowing how to write a ``for`` loop, and how to index into arrays.

DASH is organized into several different components, each implementing a particular task commonly required for paleoclimate data assimilation. The following list provides an overview of tasks supported by DASH, as well as the associated components of the toolbox

* Organize and Catalogue Climate Data: ``gridfile``, ``gridMetadata``
    Data assimilation requires diverse types of data. This can include climate proxy data sets, climate model output, and instrumental observational records. Often, these data are saved in a variety of different formats. DASH thus provides tools to load data from different formats, and to catalogue datasets with human-readable metadata.

* Build State Vector Ensembles: ``stateVector``
    The state vector ensemble is a key component of any ensemble DA method. The ``stateVector`` class allows users to flexibly design and build ensembles in a variety of styles.

* Manipulate Ensembles: ``ensemble``
    Large state vector ensembles can overwhelm computer memory, which can hinder workflows. The ``ensemble`` class allows you manipulate such ensembles, without loading them into memory. The class also includes tools for implementing evolving (time-dependent) ensembles.

* Proxy Forward Models: ``PSM`` and ``ensembleMetadata``
    There are many different proxy forward models, written in a variety of styles. DASH provides the ``PSM`` interface to allow users to run external forward modeling codes within the DASH framework. A given forward model will require a unique set of climate variables, typically at a specific spatial location, as input. The ``ensembleMetadata`` class can assist users in locating these inputs within a state vector ensemble.

* Data Assimilation Algorithms: ``kalmanFilter``, ``particleFilter``, and ``optimalSensor``
    The DASH toolbox provides utilities to implement common paleoclimate DA algorithms (and different modifications of those algorithms). Currently, the toolbox includes components to implement offline Kalman filters, offline particle filters, and an optimal sensor algorithm.
