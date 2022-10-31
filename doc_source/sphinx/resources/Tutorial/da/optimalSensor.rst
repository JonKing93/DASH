optimalSensor
==============
You can use the ``optimalSensor`` class to implement optimal sensor analyses. The optimal sensor algorithm is derived from a Kalman filter, and quantifies the ability of each proxy record to reduce uncertainty in a climate index. Here, uncertainty is defined as the variance of the climate index across an ensemble. Given a set of proxy estimates, the algorithm will update the ensemble deviations of the climate index for each proxy in the network. The amount of variance reduced by each proxy determines the proxy's ability to reduce uncertainty. As the optimal sensor is couched in a Kalman filter framework, variance reduction is primarily influenced by a proxy's uncertainties (R), and the proxy's covariance with the climate index of interest.

The ``optimalSensor`` class implements objects that run variants of this algorithm. You can use these objects to set the experimental parameters, and then run the algorithm using the indicated settings. On the remainder of this page, we'll examine the key commands and features of this class.


Essential Inputs
----------------
There are 3 essential inputs required to run an optimal sensor in DASH. These are:

1. A climate index/metric
2. Proxy estimates, and
3. Proxy uncertainties

We have discussed proxy estimates and uncertainties already in this tutorial, but the climate metric deserves discussion. Essentially, this metric is some climate index assessed across an ensemble. The metric is a vector with one element per ensemble member. Possible metrics include a global-mean temperature index, or a climate mode index like Nino 3, and there are many others.

The optimal sensor algorithm is based on an ensemble square-root Kalman filter, but only updates the ensemble deviations. As such, the method does not require actual proxy records (observations). Instead, the optimal sensor only requires proxy estimates, as these are used to estimate the covariance of each proxy record with the climate metric.


Algorithms
----------
The ``optimalSensor`` class supports 3 variations of the optimal sensor algorithm.

``optimalSensor.run``
    This variation uses an iterative greedy algorithm to rank the proxy records in a network. In each iteration, the algorithm first determines the proxy site most able to reduce metric variance. This record is used to update the metric's variance, and the proxy site is removed from the network. The algorithm then repeats with the remaining proxy sites. This algorithm can help rank the proxies in a network, and help quantify the variance constrained by assimilating successive proxies.

``optimalSensor.evaluate``
    This method assesses the variance constrained by each proxy when the proxy is the only site in the network. This method can help quantify the influence of individual proxies, even when proxy records strongly covary.

``optimalSensor.update``
    This method updates the ensemble deviations of the climate metric given a particular proxy network. This method is best used to assess the cumulative effect of a proxy network on metric uncertainty. Unlike the previous two methods, the ``update`` command accounts for proxy covariances, and so provides the most accurate assessment of variance reduction for a full proxy network.
