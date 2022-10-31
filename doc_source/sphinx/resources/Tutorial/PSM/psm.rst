PSM
===
The ``PSM`` package provides an interface that allows you to run forward models using values from a state vector ensemble. Running these forward models produces the proxy estimates required for assimilation algorithms.

Implementing forward models is beyond the scope of ``DASH``, so the ``PSM`` interface is designed to help run *external* forward modeling codes. ``DASH`` does include a single built-in forward model - a general, multi-variate linear model - but all other officially supported forward models are external codes located on Github. The interface implements ``PSM`` objects. These objects  implement different external forward models, but use a common set of commands to build and run the models.

You can create a ``PSM`` object for any of the forward models supported by ``DASH``. The object will store any parameters required to run the PSM (distinct from climate variables stored in the ensemble). Each ``PSM`` object also includes a wrapper function, which will run the actual forward model code using the specified parameters. You can create multiple objects for the same forward model - this way, you can run a forward model with different parameters for different proxy records.

We anticipate that many users will want to use forward models not officially supported by ``DASH``. To that end, ``PSM`` includes a template for adding new forward models to the toolbox. However, it's also important to note that the ``PSM`` interface is strictly meant as a convenience. You are not required to use the interface to generate proxy estimates, and it's perfectly acceptable to run the forward models outside of ``DASH`` using your own code.


Supported Forward Models
------------------------
The ``DASH`` toolbox officially supports the following forward models:

===================  ===========
     Model           Description
===================  ===========
`BayFOX`_            Bayesian model of planktic foraminiferal δ\ :sup:`18`\ O \ :sub:`c`
`BayMAG`_            Bayesian model of planktic foraminiferal Mg/Ca
`BaySPAR`_           Bayesian model for TEX86
`BaySPLINE`_         Bayesian model for UK'37
linear               General multi-variance linear model
`PDSI`_              Palmer Drought-Severity Index estimator
`PRYSM Cellulose`_   Cellulose δ\ :sup:`18`\ O sensor module
`PRYSM Coral`_       Coral δ\ :sup:`18`\ O sensor module
`PRYSM Ice-core`_    Ice-core  δ\ :sup:`18`\ O sensor module
`PRYSM Speleothem`_  Speleothm  δ\ :sup:`18`\ O sensor module
`VS-Lite`_           Vaganov-Shashkin Lite model of tree-ring width
===================  ===========

As mentioned, ``PSM`` also includes a template for adding new forward models to the toolbox. We will not be covering this in the workshop, but if you are interested, enter::

    edit PSM.template

in the console, and follow the instructions in the opened file.

.. note::
    The PRYSM forward models are written in Python and require some extra setup to run within Matlab. For the sake of time, we recommend not using the PRYSM PSM objects during the next open coding session. Instead, consider using the linear forward model as a practice run.

.. _BayFOX: https://github.com/jesstierney/bayfoxm
.. _BayMAG: https://github.com/jesstierney/BAYMAG
.. _BaySPAR: https://github.com/jesstierney/BAYSPAR
.. _BaySPLINE: https://github.com/jesstierney/BAYSPLINE
.. _PDSI: https://github.com/jonking93/pdsi
.. _PRYSM Cellulose: https://github.com/sylvia-dee/PRYSM
.. _PRYSM Coral: https://github.com/sylvia-dee/PRYSM
.. _PRYSM Ice-core: https://github.com/sylvia-dee/PRYSM
.. _PRYSM Speleothem: https://github.com/sylvia-dee/PRYSM
.. _VS-Lite: https://github.com/suztolwinskiward/vslite



Standard Workflow
-----------------
The remainder of this page will discuss the standard workflow when using the ``PSM`` interface.


Download PSMs
+++++++++++++
You can't run an external code unless the code is available on your computer. You can use the ``PSM.download`` command to download supported forward models from Github.


Create PSM Objects
++++++++++++++++++
Typically, you'll want to create a PSM object for each proxy record. You can create a PSM object for a specific forward model using ``PSM.<model name>``. For example, ``PSM.linear`` will create an object for a linear forward model, and ``PSM.bayspar`` will create an object for the BaySPAR forward model.


Locate Forward Model Inputs
+++++++++++++++++++++++++++
Next, you'll need to locate the elements of the state vector ensemble that are required to run each forward model. Every PSM object includes a ``rows`` command, which allows you to specify which state vector rows contain the inputs for a given forward model.

You'll typically use the ``ensembleMetadata`` class to locate these rows. The ``closestLatLon`` command is perhaps the most frequently used - it will search a state vector variable for the data values closest to a proxy site. Other commands that may be useful include ``ensembleMetadata.find``, which locates specific state vector variables, and ``ensembleMetadata.variable``, which returns metadata along the rows of a state vector variable.



Run Models over Ensemble
++++++++++++++++++++++++
Once you have located the inputs to each forward model, you are ready to run the models over the ensemble. The ``PSM.estimate`` command allows you to run a collection of forward models over an ensemble. This produces the proxy estimates for assimilation algorithms.
