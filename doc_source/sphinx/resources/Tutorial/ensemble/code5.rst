Open Coding 6
=============
In this section, we'll practice using some of the most common commands in the ``ensemble`` class. We'll see these commands again later in the workshop as we implement various other tasks.


Goal
----
Practice using common ``ensemble`` commands in preparation for later tasks.



Step 1: Create ``ensemble`` object
----------------------------------
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




Step 2: Return ``ensembleMetadata``
-----------------------------------
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
