Outline
=======
We're now ready to start implementing an assimilation. As a reminder, before we can run a Kalman filter, we will first need to (1) build a state vector ensemble, and then (2) combine the ensemble with forward models to generate proxy estimates. In this next lesson, we'll design and build a state vector ensemble using the ``stateVector`` class. The lesson includes:

:doc:`Concepts <concepts>`
    The process of designing state vectors will involve some new vocabulary, so we'll begin by introducing some concepts for the design process.

:doc:`Indices <indices>`
    Next, we'll take a quick look "under-the-hood" to illustrate how the ``stateVector`` class builds and selects different ensemble members.

:doc:`code3`
    Finally, we'll move into the next open-coding session. We'll examine some of the key methods in the ``stateVector`` class, and then use the class to build a state vector ensemble.


.. toctree::
    :hidden:

    Concepts <concepts>
    Indices <indices>
    code3
