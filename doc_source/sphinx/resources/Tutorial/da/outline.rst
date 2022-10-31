Outline
=======
Now that we've built the state vector ensemble and generated proxy estimates, we're ready to run an assimilation. DASH supports three DA algorithms, which are implemented by the ``kalmanFilter``, ``particleFilter``, and ``optimalSensor`` classes. Feel free to skip the tutorials for any algorithms that are not of interest to you. This section includes the pages:

:doc:`da-algorithms`
    We'll start with some brief comments about the data assimilation algorithms supported in DASH. We'll also comment on the relationship of these algorithms with other classes in the toolbox.

:doc:`kalmanFilter`
    Then, we'll examine the ``kalmanFilter`` class in detail. We'll examine the essential inputs to a Kalman filter, see supported variations of the algorithm, and explore the types of outputs produced by an assimilation.

:doc:`code8`
    We'll next use the class to run a Kalman filter assimilation.

:doc:`particleFilter`
    Next, we'll examine the ``particleFilter`` class. We'll examine its essential inputs, and different particle weighting schemes implemented by the class.

:doc:`code9`
    We'll then do a coding session to run a particle filter.

:doc:`optimalSensor`
    Finally, we'll explore the ``optimalSensor`` class. We'll explore its inputs, and the different types of analyses implemented by the class.

:doc:`code10`
    In the final coding session, we'll run an optimal sensor analysis.


.. toctree::
    :hidden:

    da-algorithms
    kalmanFilter
    code8
    particleFilter
    code9
    optimalSensor
    code10
