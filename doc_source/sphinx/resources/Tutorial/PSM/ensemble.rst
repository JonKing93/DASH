ensemble
========

Ensemble Files
--------------
At the end of the last coding session, we discussed how the ``stateVector.build`` command can save a state vector ensemble to file, rather than returning the ensemble directly as an array. In general, we recommend saving ensembles to file because it allows you to interact with the ensemble using the ``ensemble`` class.


The ``ensemble`` Class
----------------------

The ``ensemble`` class provides a number of tools for manipulating saved state vector ensembles. Notably, the class allows you to manipulate ensembles without loading them to memory. This is advantageous, as large state vector ensembles can sometimes overwhelm active computer memory. Furthermore, the class includes commands for designing evolving (time-dependent) prior ensembles.

We will not discuss ``ensemble`` in detail in this workshop. However, we'll mention a few key commands that will appear throughout the remainder of the workshop.

``ensemble`` command
++++++++++++++++++++
You can use the ``ensemble`` command to return an object that represents a saved state vector ensemble. The command takes the name of an ensemble file as input.

For example (from the NTREND demo):

.. code::
    :class: input

    ens = ensemble('ntrend.ens')

.. code::
    :class: output

    ens =

        static ensemble with properties:

              Label: NTREND Demo
          Variables: T, T_index, T_monthly
             Length: 56161
            Members: 1156

we can see that this object represents a static (time-independent) ensemble with 3 variables and 1156 ensemble members.

Analogously from the LGM demo:

.. code::
    :class: input

    ens = ensemble('lgm.ens')

.. code::
    :class: output

    ens =

        static ensemble with properties:

              Label: LGM Demo
          Variables: SST
             Length: 122880
            Members: 16

we can see the output represents an ensemble with an SST variable over 16 ensemble members.


``ensembleMetadata`` class
--------------------------
Each ``ensemble`` object can also return an ``ensembleMetadata`` object for a saved state vector ensemble. These metadata objects provide numerous utilities for working with state vectors and ensembles. We will not discuss the ``ensembleMetadata`` class in detail for the workshop, but we encourage you to read about its features in the dash documentation::

    dash.doc('ensembleMetadata')

We'll discuss a few key ``ensembleMetadata`` commands later in the workshop, as the need arises.


``ensemble.metadata``
+++++++++++++++++++++
You can use the ``ensemble.metadata`` command to return an ``ensembleMetadata`` object for a saved state vector ensemble. The command does not require any inputs.

For the NTREND demo:

.. code::
    :class: input

    ens = ensemble('ntrend');
    metadata = ens.metadata

.. code::
    :class: output

    ensembleMetadata with properties:

          Label: NTREND Demo
      Variables: T, T_index, T_monthly
         Length: 56161
        Members: 1156

      Vector:
                  T -  4320 rows   |   lon (144) x lat (30)
            T_index -     1 rows   |   lon (1) x lat (1)
          T_monthly - 51840 rows   |   lon (144) x lat (30) x time sequence (12)


Analogously for the LGM Demo:

.. code::
    :class: input

    metadata = ensemble('lgm').metadata

.. code::
    :class: output

      ensembleMetadata with properties:

            Label: LGM Demo
        Variables: SST
           Length: 122880
          Members: 16

        Vector:
            SST - 122880 rows   |   site (122880) x time (1)
