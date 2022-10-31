Coding 10
=========

Goal
----
Use the ``optimalSensor`` class to implement an assimilation.


Step 1: Create ``optimalSensor`` object
---------------------------------------
We'll start by using the ``optimalSensor`` command to create an object. The syntax is::

    obj = optimalSensor

where **obj** is the new ``optimalSensor`` object. You can optionally use the second input to label the object::

    obj = optimalSensor(label)

where **label** is a string.

.. tip::

    You can also use the ``optimalSensor.label`` command to label the object at any later point.




..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-1"><label for="ntrend-1"><strong>NTREND Demo</strong></label><div class="content">

Here, we'll create a ``kalmanFilter`` object for the NTREND demo. We'll also apply a label to the object::

    label = "NTREND Demo";
    os = optimalSensor(label);

Inspecting the object:

.. code::
    :class: input

    disp(os)

.. code::
    :class: output

    optimalSensor with properties:

                Label: NTREND Demo

               Metric: none
            Estimates: none
        Uncertainties: none

we can see the initialize ``optimalSensor`` object. We can see that none of the essential inputs have been set yet.

.. raw:: html

    </div></section>


Step 2: Essential Inputs
------------------------
Next, we'll use the ``metric``, ``estimates``, and ``uncertainties`` commands to provide the essential inputs to the optimal sensor. All three commands use a similar base syntax - each command takes a data array as input, and outputs an updated ``optimalSensor`` object::

    obj = obj.metric(X)
    obj = obj.estimates(Ye)
    obj = obj.uncertainties(R)

**X**
    The climate metric should be a vector with one element per ensemble member.

**Ye**
    The proxy estimates should be a matrix with one row per proxy record, and one column per ensemble member.

**R**
    The proxy uncertainties should be a data matrix holding either error-variances or a full error-covariance matrix. If using error variances, the uncertainties should be a column vector with one row per proxy record. If using error-covariances, the matrix should be symmetric with one row and one column per proxy record.


..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-2"><label for="ntrend-2"><strong>NTREND Demo</strong></label><div class="content">

We'll use the input commands to provide the data values for our optimal sensor analyses. We'll start by providing the climate metric. Here, we'll use the **T_index** variable from our ensemble. We can use the ``ensemble.useVariables`` and ``ensemble.load`` commands to load this metric directly. (You can find a detailed discussion of the ``useVariables`` command here: :ref:`ensemble.useVariables`)::

    % Load the "T_index" variable from the ensemble
    ens = ensemble('ntrend');
    ens = ens.useVariables("T_index");
    T_index = ens.load;

    % Use as the optimal sensor metric
    os = os.metric(T_index);

We previously generated the proxy estimates using the ``PSM.estimate`` command, so we'll provide those next::

    % Provide proxy estimates
    os = os.estimates(Ye);

Finally, we'll provide proxy uncertainties - specifically, error variances. These values are provided in the ``ntrend.mat`` file, and were produced by (1) running the forward models on instrumental observations, and then (2) comparing the instrumental proxy estimates to the real instrumental proxy records::

    % Load the proxy uncertainties
    data = load('ntrend.mat', 'R');
    R = data.R;

    % Provide the uncertainties to the optimal sensor
    os = os.uncertainties(R);

Inspecting the updated object:

.. code::
    :class: input

    disp(os)

.. code::
    :class: output

    optimalSensor with properties:

                    Label: NTREND Demo

                   Metric: set
                Estimates: set
            Uncertainties: set (variances)

        Observation Sites: 54
         Ensemble Members: 1156

we can see that the optimal sensor now has all three essential inputs. The output also shows two key sizes - the number of observations sites, and the number of ensemble members.

.. raw:: html

    </div></section>


Step 3: ``optimalSensor.run``
-----------------------------
We'll next use the ``optimalSensor.run`` command to run the greedy algorithm. The base syntax is::

    [optimalSites, variance, metric] = obj.run

**optimalSites**
    This vector indicates which site was the "optimal" site for each iteration of the algorithm. Each element holds the index of one of the sites in the proxy network. These indices are relative to the input proxy network, and are not affected by the decreasing size of the network with each algorithm iteration.

**variance**
    This vector indicates the variance of the climate metric *after* each iteration of the algorithm.

**metric**
    This matrix indicates the climate metric after each algorithm iteration. Each row holds the ensemble at the end of an iteration, and each column holds the values for an ensemble member.


..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-3"><label for="lgm-3"><strong>LGM Demo</strong></label><div class="content">

Here, we'll run the greedy algorithm::

    [optimalSites, variance, metric] = os.run;

Examining the first 5 optimal sites:

.. code::
    :class: input

    optimalSites(1:5)

.. code::
    :class: output

     2
     3
    52
     7
     4

we can see that proxy site 2 was the most optimal site in the network. After site 2 is used to update the climate metric, site 3 is the next-most optimal site. After site 3 is used to updated the metric, site 52 is the next most valuable and so on.

We can use the variance output to examine how the variance of the metric changes as each of these site is assimilated:

.. code::
    :class: input

    variance(1:5)

.. code::
    :class: output

    0.27035
    0.26537
    0.26079
    0.25839
    0.25629

.. raw:: html

    </div></section>



Step 4: ``optimalSensor.evaluate``
----------------------------------
Next, we'll use the ``evaluate`` command to assess the ability of proxy site to reduce variance as the only proxy in the network. This will allow us to quantify proxy influence without the confounding variables of other covarying proxy sites. The syntax for this command is::

    deltaVariance = os.evaluate

**deltaVariance**
    This vector indicates the total reduction in variance caused by each individual proxy site in the network.

Note that the total variance reduced by a proxy network will be smaller than the sum of **deltaVariance**. This is because covariance between proxy sites reduces the effects of individual proxies.


..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-4"><label for="lgm-4"><strong>LGM Demo</strong></label><div class="content">

Here, we'll run the evaluation algorithm:

.. code::
    :class: input

    deltaVariance = os.run

.. code::
    :class: output

    54×1 single column vector

      0.0035785
       0.010422
      0.0075898
      ...
      0.0045732
     1.7153e-06
      0.0018802


If we rank the proxy sites by their ability to reduce variance::

[~, rank] = sort(deltaVariance, 'descend')

and examine the 5 best proxy sites:

.. code::
    :class: input

    rank(1:5)

.. code::
    :class: output

     2
     3
     4
    52
     8

we can see that the sites differ slightly from the results of the greedy algorithm. In particular, sites 4 and 8 appear to have a higher rank in the evaluation than in the greedy algorithm. This is because sites 4 and 8 covary strongly with sites 2 and 3. Because of this covariance, these sites share a portion of the total variance reduction. However, in the greedy algorithm, all of this shared variance reduction is assigned to sites 2 and 3, because these sites are selected earlier in the algorithm. Consequently, sites 4 and 8 receive a lower rank.

By contrast, the ``evaluate`` command allows us to begin to disentangle the effects these covariances, and we can see that the individual influence of site 4 is the third-highest in the network. Similarly, site 8 has the 5th most influence in the network.

.. raw:: html

    </div></section>



Step 5: ``optimalSensor.update``
--------------------------------
The ``update`` command allows you to assess the total reduction in variance that occurs for a proxy network. As mentioned, the ``evaluate`` command deliberately removes the effects of proxy covariance, and so cannot be used to accurately assess the total reduction of variance for a network. Similarly, each iteration of the greedy algorithm updates proxy estimates linearly via the Kalman Gain - this is not appropriate for non-linear forward models, and for covarying proxy uncertainties, so the ``run`` command should also not be used to evaluate total reduction of variance. Instead, use the ``update`` method, which accounts for these factors. Here the syntax is::

    [variance, metric] = os.update

**variance**
    This scalar reports the final variance of the metric after the full proxy network is used to update the ensemble.

**metric**
    This vector returns the updated metric across the ensemble.



..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-5"><label for="lgm-5"><strong>LGM Demo</strong></label><div class="content">

Here, we'll run the update::

    [variance, metric] = os.update

Inspecting the final variance:

.. code::
    :class: input

    disp(variance)

.. code::
    :class: output

    0.24022

we can see that assimilating the entire proxy network will reduce metric variance to 0.24022.
