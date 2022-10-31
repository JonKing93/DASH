Coding 9
========

Goal
----
Use the ``particleFilter`` class to run a particle filter assimilation.


Step 1: Create ``particleFilter`` object
----------------------------------------
We'll start by using the ``particleFilter`` command to create an object. The syntax is::

    obj = particleFilter

    where **obj** is the new ``particleFilter`` object. You can optionally use the second input to label the object::

        obj = particleFilter(label)

    where **label** is a string.

    .. tip::

        You can also use the ``particleFilter.label`` command to label the object at any later point.



..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-1"><label for="lgm-1"><strong>LGM Demo</strong></label><div class="content">

Here, we'll create a ``particleFilter`` object for the LGM demo. We'll also apply a label to the object::

    label = "LGM Demo";
    pf = particleFilter(label);

Inspecting the object:

.. code::
    :class: input

    disp(pf)

.. code::
    :class: output

    particleFilter with properties:

            Observations: none
                   Prior: none
               Estimates: none
           Uncertainties: none

        Weighting Scheme: Bayesian

we can see the initialized particle filter. We can see that none of the 4 essential inputs (observations, prior, estimates, and uncertainties) have been set yet. We can also see that the object will use the default Bayesian weighting scheme when running the particle filter algorithm.

.. raw:: html

    </div></section>



Step 2: Essential Inputs
------------------------

Next, we'll use the ``prior``, ``observations``, ``estimates``, and ``uncertainties`` commands to provide essential inputs to the particle filter. All four commands use a similar base syntax - each command takes a data array as input, and outputs an updated ``particleFilter`` object::

    obj = obj.prior(X)
    obj = obj.observations(Y)
    obj = obj.estimates(Ye)
    obj = obj.uncertainties(R)

**X**
    The prior may either be provided via an ``ensemble`` object or as a data matrix. If using a matrix, each row should be an element of the state vector, and each column should be an ensemble member.

**Y**
    The proxy observations should be a data matrix. Each row holds a particular proxy record and each column holds the values for an assimilation time step. You can use a NaN value when a proxy record does not have values for a particular time step.

**Ye**
    The proxy estimates should be a matrix with one row per proxy record, and one column per ensemble member.

**R**
    The proxy uncertainties should be a data matrix holding either error-variances or a full error-covariance matrix. If using error variances, the uncertainties should be a column vector with one row per proxy record. If using error-covariances, the matrix should be symmetric with one row and one column per proxy record.

You can also modify these commands to use different values in different assimilation time steps. (For example, to use an evolving prior). We will not discuss this syntax in the tutorial, but you can read about it in the DASH documentation.



*Select Reconstruction Targets*
+++++++++++++++++++++++++++++++
When providing an assimilation prior, the prior only needs to contain state vector variables that represent reconstruction targets. Since we already generated proxy estimates, we don't need to assimilate variables used only as forward model inputs. You can use the ``ensemble.useVariables`` command to restrict an ensemble object to specific state vector variables. The syntax for the command is::

    obj = obj.useVariables(variables)

**variables**
    The input should list the names or indices of specific variables in the state vector ensemble.

**obj**
    The output is an updated ensemble object.



..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-2"><label for="lgm-2"><strong>LGM Demo</strong></label><div class="content">

We'll use the four input commands to provide the essential data values for our assimilation. We'll start by providing the prior using an ensemble object::

    % Get the ensemble object
    ens = ensemble('lgm');

    % Provide the ensemble to the particle filter
    pf = pf.prior(ens);

Next, we'll provide the proxy records. The proxy records are catalogued in ``uk37.grid``, so we'll first use the ``gridfile.load`` command to load them as a data array::

    % Load the proxy records
    proxies = gridfile('uk37');
    Y = proxies.load;

    % Provide the proxy records to the particle filter
    pf = pf.observations(Y);

Next, we'll provide the proxy estimates (Ye) and uncertainties (R). We generated both of these in coding session 7::

    % Provide proxy estimates and uncertainties
    pf = pf.estimates(Ye);
    pf = pf.uncertainties(R);

Inspecting the updated ``particleFilter`` object:

.. code::
    :class: input

    disp(pf)

.. code::
    :class: output

    particleFilter with properties:

                      Label: LGM Demo

               Observations: set
                      Prior: static
                  Estimates: set
              Uncertainties: variances

          Observation Sites: 89
        State Vector Length: 122880
           Ensemble Members: 16
                     Priors: 1
                 Time Steps: 1

           Weighting Scheme: Bayesian

we can see that the particle filter now includes all four essential inputs. We can see it uses a static (time-independent) prior, and error-variances for the uncertainties. The output also shows a few key sizes, such as the number of observations sites, prior, assimilation time steps, etc.

.. raw:: html

   </div></section>



Step 3: Weighting Scheme
------------------------
You can adjust the particle filter weighting scheme using the ``particleFilter.weights`` command. You can use::

    obj = obj.weights('bayes')

to select the default Bayesian weighting scheme, or alternatively::

    obj = obj.weights('best', N)

to implement the "Best N" weighting scheme. Here, **N** is the number of best particles to use to compute the update.


..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-3"><label for="lgm-3"><strong>LGM Demo</strong></label><div class="content">

Here, we'll adjust the particle filter to use the "Best N" weighting scheme rather than the Bayesian scheme. We'll specifically compute the update using the best 5 particles:

.. code::
    :class: input

    % Use the Best N weighting scheme
    N = 5;
    pf = pf.weights('best', N)

.. code::
    :class: output

    particleFilter with properties:

                      Label: LGM Demo

               Observations: set
                      Prior: static
                  Estimates: set
              Uncertainties: variances

          Observation Sites: 89
        State Vector Length: 122880
           Ensemble Members: 16
                     Priors: 1
                 Time Steps: 1

           Weighting Scheme: Best 5 particles

From the output, we can see that the ``particleFilter`` object will now compute the update using the best 5 particles.

.. raw:: html

    </div></section>



Step 4: Run the filter
----------------------
We're now ready to run the particle filter algorithm. We'll do this using the ``particleFilter.run`` command. The base syntax is::

    output = obj.run;

The output is a struct with two fields:

**A**
    This matrix is the update (analysis) for each assimilated time step. Each row is a state vector element, and each column is the update for an assimilated time step.

**weights**
    This matrix reports the weights for each particle in each time step. It has one row per ensemble member (particle), and one column per assimilation time step.


..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-4"><label for="lgm-4"><strong>LGM Demo</strong></label><div class="content">

Here, we'll run the particle filter:

.. code::
    :class: input

    output = pf.run

.. code::
    :class: output

    output =

      struct with fields:

              A: [122880×1 double]
        weights: [16×1 double]

Inspecting the weights:

.. code::
    :class: input

    output.weights

.. code::
    :class: output

        0
        0
      0.2
        0
        0
        0
        0
        0
      0.2
      0.2
        0
      0.2
        0
        0
      0.2
        0

we can see the weight applied to each ensemble member. Using Bayes' formula, ensemble members 3, 9, 10, 13, and 15 were selected as the best 5 particles in the ensemble. The five particles were then given equal weights, and all other particles were given a weight of 0. The updated analysis is the weighted mean of these best 5 particles.


Step 5: Regrid state vector variables
-------------------------------------
At this point, you'll typically want to start mapping and visualizing the assimilation outputs. However, the assimilated variables are still organized as state vectors, which can hinder visualization. You can use the ``ensembleMetadata.regrid`` command to (1) extract a variable from a state vector, and (2) return the variable to its original data grid.

Check out the section on :ref:`regridding state vector variables <regrid>` in the Kalman filter tutorial for a detailed discussion of this command.



Step 6: Visualize!
------------------
That's it, the assimilation is complete! Try visualizing some of the outputs. Plotting data is outside of the scope of DASH, so use whatever mapping and visualization tools you prefer. You may be interested in:

* `Matlab's mapping toolbox <https://www.mathworks.com/help/map/index.html>`_, and
* `The m_map package <https://www.eoas.ubc.ca/~rich/map.html>`_

and there are many other resources built in to Matlab, as well as online.


Full Demo
---------
This section recaps all the essential code from the demos and may be useful as a quick reference.


..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-full"><label for="lgm-full"><strong>LGM Demo</strong></label><div class="content">

::

    % Load the proxy data catalogue, and the prior ensemble/its metadata
    proxies = gridfile('UK37');
    ens = ensemble('lgm');
    ensMeta = ens.metadata;

    % Create a particle filter object
    pf = particleFilter('LGM demo');

    % Collect essential inputs
    X = ens;
    Y = proxies.load;
    % Ye     (from PSM.estimate)
    % R      (from PSM.estimate)

    % Provide essential inputs to the filter
    pf = pf.prior(ens);
    pf = pf.observations(Y);
    pf = pf.estimates(Ye);
    pf = pf.uncertainties(R);

    % Select a weighting scheme
    N = 5;
    pf = pf.weights('best', N);

    % Run the filter
    output = pf.run;
