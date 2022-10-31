Tutorial Outline
================
From the primer, we can see a few common tasks for implementing DA. These include:

1. Organizing climate data
2. Building a state vector ensemble,
3. Running forward models on the ensemble,
4. Estimating proxy uncertainties, and
5. Running assimilation algorithms

In this tutorial, we will use the DASH toolbox to implement all these tasks. We'll practice using DASH using some demo datasets, which we'll provide a bit later. The demo datasets are from published assimilations, and should give sense of typical DASH workflows. The remainder of the tutorial is organized as follows:

:doc:`DASH Introduction <dash/outline>`
    We'll start by introducing the DASH toolbox. We'll briefly examine its command style, layout, and how to access the documentation.

:doc:`Demo Datasets <demos/outline>`
    Next, we'll introduce and download the demo datasets. We'll also use a few DASH utilities to examine metadata for these datasets.

:doc:`Catalogue Climate Datasets <gridfile/outline>`
    At this point, we'll begin using DASH to implement an assimilation. We'll start by using DASH's ``gridMetadata`` and ``gridfile`` classes to describe and catalogue climate datasets.

:doc:`Build a State Vector <stateVector/outline>`
    Once our data is catalogued, we'll use DASH's ``stateVector`` class to design and build a state vector ensemble.

:doc:`Manipulate Ensembles <ensemble/outline>`
    Next, we'll examine the ``ensemble`` class and use it to manipulate our state vector ensembles. We also briefly explore the ``ensembleMetadata`` class, which helps locate and organize data within an ensemble.

:doc:`Implement Forward models <PSM/outline>`
    Next, we'll use the ``PSM`` interface to run forward models on climate variables in the ensemble. We'll also use a number of ``ensembleMetadata`` methods to locate forward model inputs.

:doc:`Run DA Algorithms <da/outline>`
    With this setup complete, we can now start running DA algorithms. We'll examine the ``kalmanFilter``, ``particleFilter``, and ``optimalSensor`` classes and use each of them to run an assimilation.
