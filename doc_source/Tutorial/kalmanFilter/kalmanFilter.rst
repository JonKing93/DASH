kalmanFilter
============

You can use the ``kalmanFilter`` class to implement an offline ensemble Kalman filter assimilation algorithm. The class implements ``kalmanFilter`` objects. You can use these objects to set the experimental parameters and data inputs for a particular analysis, and then run the algorithm using the indicated settings. On the remainder of this page, we'll examine key commands and features for this class.


Essential Inputs
----------------
There are 4 essential data inputs required to run a Kalman filter in DASH. These are

1. A prior ensemble
2. Proxy records (often called proxy *observations*)
3. Proxy estimates, and
4. Proxy uncertainties

You can provide each of these inputs to a Kalman filter object using the associated ``kalmanFilter`` input command. These commands are ``prior``, ``observations``, ``estimates``, and ``uncertainties``.


Covariance Adjustments
----------------------
The Kalman filter algorithm estimates the covariance between proxy records and state vector elements and relies on this covariance to update the ensemble. As such, a number of studies have implemented algorithm variants that modify these covariance estimates. To facilitate these variant algorithms, the ``kalmanFilter`` class supports the following covariance adjustments:

**Inflation**
    Multiplies the covariance estimate by a scalar to increase the magnitude of updates. See the ``kalmanFilter.inflate`` command.

**Localization**
    Restricts proxy influence within a specific geographical region. This can reduce sampling errors at reconstructed sites far from the proxy network. See the ``kalmanFilter.localize`` command and also the localization schemes in the ``dash.localize`` subpackage.

**Blending**
    Covariance blending combines each covariance estimate with a second covariance. The second covariance is typically a "climatological" covariance calculated from an ensemble larger than the ensemble used for assimilation. This approach can help reduce sampling errors when using a small evolving ensemble. See ``kalmanFilter.blend`` to implement blending.

**Set Covariance Directly**
    In some cases, covariance is poorly defined (for example, for changing continental configurations). Alternatively, you may want to implement a new algorithm variant not supported by DASH. In either case, you can use the ``kalmanFilter.setCovariance`` command to directly modify the covariance estimates. See also the ``kalmanFilter.covariance`` command to return the unmodified covariance estimates.


Output Options
--------------
The ``kalmanFilter`` class relies on an ensemble square root Kalman filter, which updates the ensemble mean separately from the ensemble deviations. Updating the deviations is computationally intensive, and the updated deviations can quickly overwhelm computer memory. Often, you'll only need the variance of the deviations, or a few select percentiles, so the ``kalmanFilter`` class includes several commands that allow you to select the quantities output by the algorithm.

By default, the class will only update and return the ensemble mean when you run the algorithm. This updated ensemble mean is typically sufficient for exploratory analyses, and this approach is significantly faster than also updating the deviations. However, the updated deviations are important for uncertainty analyses, and you'll typically want to use them in conjunction with a final reconstruction. The following ``kalmanFilter`` commands will cause the algorithm to update the ensemble deviations and return an associated output field.

``deviations``
    Returns the full set of updated ensemble deviations. This option allows the most flexibility for uncertainty analyses. However, updated deviations can overwhelm computer memory when assimilating a large state vector or many time steps, so this option may not always be the most appropriate.

``variance``
    Returns the variance of the deviations across the updated ensemble.

``percentiles``
    Return specified percentiles of the updated ensemble

----

Sometimes, you may be interested in using an updated climate field to reconstruct a climate index. For example, you might assimilate a global temperature field and then use the updated field to calculate a global temperature index. In this case, the updated deviations of the reconstructed climate index are often useful for uncertainty analysis. However, calculating the deviations for the index requires the deviations for the full field, and field deviations can quickly overwhelm computer memory. The ``kalmanFilter`` class provides the ``index`` command to resolve this issue.

``index``
    Return the full set of deviations for a climate index calculated from the updated ensemble, without needing to return the deviations for the full state vector.


Run the filter
--------------
After providing the essential inputs (prior, observations, estimates, and uncertainties), you can run the Kalman filter algorithm using the ``run`` command. The algorithm will implement any specified covariance adjustments and output options.
