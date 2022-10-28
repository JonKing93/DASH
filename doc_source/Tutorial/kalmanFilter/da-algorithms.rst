DA Algorithms in DASH
=====================

The DASH toolbox contains code to implement three different data assimilation algorithms - specifically, the toolbox supports Kalman filter, particle filter, and optimal sensor analyses. Each of these algorithms is implemented by a class - specifically ``kalmanFilter``, ``particleFilter``, and ``optimalSensor``. Each class implements an object that can be used to (1) set experimental parameters for a particular analysis, and (2) run the algorithm using those parameters. In this workshop, we'll focus on using a Kalman filter, but you can find a summary of the other algorithms in the next section.

It's important to note that the DA algorithms in DASH are independent of the rest of the toolbox. The other classes (``stateVector``, ``PSM``, etc.) are strictly meant for your convenience. They are not required to implement an assimilation, and you can run any assimilation without them. However, we've included them in the workshop because we find they ultimately accelerate DA workflows.


Algorithm Descriptions
----------------------
The following section contains a brief description of the DA algorithms in DASH. You can find additional details within the DASH documentation and the paleoclimate DA literature.

**Kalman Filter**
    The Kalman filter algorithm uses proxy estimates to estimate the covariance between proxy records and state vector elements. These covariances are down-weighted by the uncertainty associated with the innovation for each proxy record. The algorithm combines these covariances with the proxy innovations to update the ensemble members.

**Particle Filter**
    The particle filter uses the proxy estimates and uncertainties to determine the similarity of each ensemble member to the proxy records. The algorithm uses these similarities to weight the ensemble members. These weights can be used to select the most similar ensemble member, or to implement a weighted mean over the ensemble. The most similar member or weighted mean is the updated ensemble.

**Optimal Sensor**
    The optimal sensor algorithm is derived from a Kalman filter framework, but does not require proxy observations and does not update the ensemble. Instead, the algorithm is built around a climate metric calculated over an ensemble. The algorithm uses proxy estimates and uncertainties to quantify each proxy record's ability to reduce uncertainty in this climate metric.
