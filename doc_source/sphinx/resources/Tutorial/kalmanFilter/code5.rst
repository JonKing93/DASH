Open Coding 5
=============

Goal
----
In this session, we will use the ``kalmanFilter`` class to run an assimilation.


Step 1: Create ``kalmanFilter`` object
--------------------------------------
We'll start by using the ``kalmanFilter`` command to create an object. The syntax is::

    obj = kalmanFilter

where **obj** is the new ``kalmanFilter`` object. You can optionally use the second input to label the object::

    obj = kalmanFilter(label)

where **label** is a string.

.. tip::

    You can also use the ``kalmanFilter.label`` command to label the object at any later point.





..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-1"><label for="ntrend-1"><strong>NTREND Demo</strong></label><div class="content">

Here, we'll create a ``kalmanFilter`` object for the NTREND demo. We'll also apply a label to the object::

    label = "NTREND Demo";
    kf = kalmanFilter(label);

Inspecting the object:

.. code::
    :class: input

    disp(kf)

.. code::
    :class: output

    kalmanFilter with properties:

                Label: NTREND Demo

         Observations: none
                Prior: none
            Estimates: none
        Uncertainties: none

            Returning:
                Mean

we can see the initialized Kalman filter. We can see that none of the 4 essential inputs (observations, prior, estimates, and uncertainties) have been set yet. We can also see that the object will only update and return the ensemble mean when running the Kalman filter algorithm.

.. raw:: html

    </div></section>




..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-1"><label for="lgm-1"><strong>LGM Demo</strong></label><div class="content">

Here, we'll create a ``kalmanFilter`` object for the LGM temperature assimilation. We'll also apply a label to the object::

    label = "LGM Demo";
    kf = kalmanFilter(label);

Inspecting the object:

.. code::
    :class: input

    disp(kf)

.. code::
    :class: output

    kalmanFilter with properties:

                Label: LGM Demo

         Observations: none
                Prior: none
            Estimates: none
        Uncertainties: none

            Returning:
                Mean

we can see the initialized Kalman filter. We can see that none of the 4 essential inputs (observations, prior, estimates, and uncertainties) have been set yet. We can also see that the object will only update and return the ensemble mean when running the Kalman filter algorithm.

.. raw:: html

    </div></section>



Step 2: Essential Inputs
------------------------

Next, we'll use the ``prior``, ``observations``, ``estimates``, and ``uncertainties`` commands to provide essential inputs to the Kalman filter. All four commands use a similar base syntax - each command takes a data array as input, and outputs an updated ``kalmanFilter`` object::

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

You can also modify these commands to use different values in different assimilation time steps. (For example, to use an evolving prior). We will not discuss this syntax in the workshop, but you can read about it in the DASH documentation.


*Select Reconstruction Targets*
+++++++++++++++++++++++++++++++
When providing an assimilation prior, the prior only needs to contain state vector variables that represent reconstruction targets. Since we already generated proxy estimates, we don't need to assimilate variables used only as forward model inputs. You can use the ``ensemble.useVariables`` command to restrict an ensemble object to specific state vector variables. The syntax for the command is::

    obj = obj.useVariables(variables)

**variables**
    The input should list the names or indices of specific variables in the state vector ensemble.

**obj**
    The output is an updated ensemble object.






..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-2"><label for="ntrend-2"><strong>NTREND Demo</strong></label><div class="content">

We'll use the four input commands to provide the essential data values for our assimilation. We'll start by providing the prior. Our prior will consist of the reconstruction targets **T** and **T_index**. We'll use the ``ensemble.useVariables`` command to limit the reconstruction to these two variables::

    % Get an ensemble object
    ens = ensemble('ntrend');

    % Restrict the object to reconstruction target variables
    variables = ["T", "T_index"];
    ens = ens.useVariables(variables);

    % Provide the ensemble to the Kalman filter
    kf = kf.prior(ens);

Next, we'll provide the proxy records. The proxy records are catalogued in ``ntrend.grid``, so we'll first use the ``gridfile.load`` command to load them as a data array::

    % Load the proxy estimates
    proxies = gridfile('ntrend');
    Y = proxies.load;

    % Provide the proxy records to the Kalman filter
    kf = kf.observations(Y);

Next, we'll provide the proxy estimates (Ye). We generated these proxy estimates in the previous open coding session::

    % Provide the proxy estimates
    kf = kf.estimates(Ye);

Finally, we'll provide proxy uncertainties - specifically, error variances. These values are provided in the ``ntrend.mat`` file, and were produced by (1) running the forward models on instrumental observations, and then (2) comparing the instrumental proxy estimates to the real instrumental proxy records::

    % Load the proxy uncertainties
    data = load('ntrend.mat', 'R');
    R = data.R;

    % Provide the uncertainties to the Kalman filter
    kf = kf.uncertainties(R);

Inspecting the updated ``kalmanFilter`` object:

.. code::
    :class: input

    disp(kf)

.. code::
    :class: output

    kalmanFilter with properties:

                      Label: NTREND Demo

               Observations: set
                      Prior: static
                  Estimates: set
              Uncertainties: variances

          Observation Sites: 54
        State Vector Length: 4321
           Ensemble Members: 1156
                     Priors: 1
                 Time Steps: 1262

                  Returning:
                      Mean

we can see that the Kalman filter now includes all four essential inputs. We can see it uses a static (time-independent) prior, and error-variances for the uncertainties. The output also shows a few key sizes, such as the number of observations sites, prior, assimilation time steps, etc.

.. raw:: html

    </div></section>



..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-2"><label for="lgm-2"><strong>LGM Demo</strong></label><div class="content">

We'll use the four input commands to provide the essential data values for our assimilation. We'll start by providing the prior using an ensemble object::

    % Get the ensemble object
    ens = ensemble('lgm');

    % Provide the ensemble to the Kalman filter
    kf = kf.prior(ens);

Next, we'll provide the proxy records. The proxy records are catalogued in ``uk37.grid``, so we'll first use the ``gridfile.load`` command to load them as a data array::

    % Load the proxy records
    proxies = gridfile('uk37');
    Y = proxies.load;

    % Provide the proxy records to the Kalman filter
    kf = kf.observations(Y);

Next, we'll provide the proxy estimates (Ye) and uncertainties (R). We generated both of these in the previous coding session::

    % Provide proxy estimates and uncertainties
    kf = kf.estimates(Ye);
    kf = kf.uncertainties(R);

Inspecting the updated ``kalmanFilter`` object:

.. code::
    :class: input

    disp(kf)

.. code::
    :class: output

    kalmanFilter with properties:

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

                  Returning:
                      Mean

we can see that the Kalman filter now includes all four essential inputs. We can see it uses a static (time-independent) prior, and error-variances for the uncertainties. The output also shows a few key sizes, such as the number of observations sites, prior, assimilation time steps, etc.

.. raw:: html

    </div></section>



Step 3: Covariance Adjustments
------------------------------
In this workshop, we'll focus on covariance localization, but feel free to try out other covariance adjustments. You can implement localization using the ``kalmanFilter.localize`` command. It's syntax is::

    obj = obj.localize(wloc, yloc)

where **wloc** and **yloc** are the localization weights between (1) the proxy estimates and state vector elements, and (2) the proxy estimates and one another. The ``dash.localize`` package contains functions for calculating localization weights. We'll use the ``gc2d`` function, which implements a Gaspari-Cohn 5th order polynomial in 2 dimensions (this is a standard localization scheme for paleoclimate DA). The syntax for this command is::

    [wloc, yloc] = dash.localize.gc2d(stateCoordinates, proxyCoordinates, R)

**stateCoordinates**
    The first input lists the latitude-longitude coordinate of each element in the state vector. This is a matrix with one row per state vector element, and 2 columns. The first column is latitude, and the second is longitude.

**proxyCoordinates**
    The second input lists the latitude-longitude coordinate of each proxy site. This is a matrix with one row per proxy record and 2 columns. As before, the first column is latitude, and the second is longitude.

**R**
    The third input lists the localization radius in kilometers.






..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-3"><label for="ntrend-3"><strong>NTREND Demo</strong></label><div class="content">

In this demo, we'll implement covariance localization with a localization radius of 15,000 km. We'll start by using the metadata in ``ntrend.grid`` to obtain the proxy coordinates::

    % Load the metadata for each site
    site = gridfile('ntrend').metadata.site;
    lats = str2double(site(:,2));
    lons = str2double(site(:,3));

    % Get the proxy coordinates
    proxyCoordinates = [lats, lons];

Next, we'll use the ``ensembleMetadata.latlon`` command to return latitude-longitude coordinates for each element in the state vector. (Note that we'll first use the ``ensemble.useVariables`` command to restrict the ensemble to the **T** and **T_index** reconstruction targets)::

    % Get the ensemble object for the reconstruction targets
    ens = ensemble('ntrend');
    ens = ens.useVariables(["T", "T_index"]);

    % Get the ensembleMetadata object
    ensMeta = ens.metadata;

    % Get the latitude-longitude coordinates for the state vector
    stateCoordinates = ensMeta.latlon;

With these coordinates, we'll use the ``dash.localize.gc2d`` function to calculate localization weights::

    % Calculate localization weights for a 15000 km radius
    R = 15000;
    [wloc, yloc] = dash.localize.gc2d(stateCoordinates, proxyCoordinates, R);

Finally, we'll provide the localization weights to the ``kalmanFilter`` object::

    kf = kf.localize(wloc, yloc);

Inspecting the updated object:

.. code::
    :class: input

    disp(kf)

.. code::
    :class: output

    kalmanFilter with properties:

                      Label: NTREND Demo

               Observations: set
                      Prior: static
                  Estimates: set
              Uncertainties: variances

          Observation Sites: 54
        State Vector Length: 4321
           Ensemble Members: 1156
                     Priors: 1
                 Time Steps: 1262

                 Covariance:
                      Localization

                  Returning:
                      Mean

we can see that the object will now implement covariance localization when running a Kalman filter.

.. raw:: html

    </div></section>



..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-3"><label for="lgm-3"><strong>LGM Demo</strong></label><div class="content">

In this demo, we'll implement covariance localization with a localization radius of 22,000 km. We'll start by using the metadata in ``UK37.grid`` to obtain the proxy coordinates::

    % Load the metadata for each site
    site = gridfile('uk37').metadata.site;
    lats = str2double(site(:,2));
    lons = str2double(site(:,3));

    % Get the proxy coordinates
    proxyCoordinates = [lats, lons];

Next, we'll use the ``ensembleMetadata.latlon`` command to return latitude-longitude coordinates for each element in the state vector. Our **SST** variable is located on a tripolar grid, so DASH treats the climate model output as a collection of unique spatial sites. The spatial metadata is thus organized along the "site" dimension, rather than "lat" and "lon". Because of this we'll use the first input to the ``latlon`` command to indicate that the first column of "site" metadata corresponds to latitude, and the second column is longitude::

    % Get the ensembleMetadata object
    ensMeta = ensemble('lgm').metadata;

    % Get the latitude-longitude coordinates
    siteColumns = [1 2];
    stateCoordinates = ensMeta.latlon([1 2]);

With these coordinates, we'll use the ``dash.localize.gc2d`` function to calculate localization weights::

    % Calculate localization weights for a 15000 km radius
    R = 22000;
    [wloc, yloc] = dash.localize.gc2d(stateCoordinates, proxyCoordinates, R);

Finally, we'll provide the localization weights to the ``kalmanFilter`` object::

    kf = kf.localize(wloc, yloc);

Inspecting the updated object:

.. code::
    :class: input

    disp(kf)

.. code::
    :class: output

    kalmanFilter with properties:

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

                 Covariance:
                      Localization

                  Returning:
                      Mean

we can see that the object will now implement covariance localization when running a Kalman filter.

.. raw:: html

    </div></section>



Step 4: Select outputs
----------------------
As mentioned, you can use various commands to indicate that the Kalman filter should return specific outputs. In this workshop, we'll focus on the ``kalmanFilter.variance`` and ``kalmanFilter.deviations`` commands, which share a similar syntax. Use::

    obj = obj.variance(true)

to return the variance of the posterior ensemble and::

    obj = obj.deviations(true)

to return the full ensemble deviations. These outputs will be labeled as **Avar** and **Adev** in the Kalman filter output.

You can also use the ``kalmanFilter.percentiles`` command to return specific percentiles of the posterior ensemble. Here the syntax is::

    obj = obj.percentiles(percentages)

where the **percentages** input is a vector of percentages for which to compute percentiles. The percentiles will be labeled as **Aperc** in the Kalman filter output.





..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-4"><label for="ntrend-4"><strong>NTREND Demo</strong></label><div class="content">

In this demo, we'll return the variance and quartiles of the posterior ensemble. First, we'll use the ``variance`` command to indicate that the algorithm should update the ensemble deviations and return ensemble variance::

    kf = kf.variance(true);

Then, we'll use the ``percentiles`` command to also request the quartiles of the ensemble as output::

    percentages = [25 50 75];
    kf = kf.percentiles(percentages);

Inspecting the updated object:

.. code::
    :class: input

    disp(kf)

.. code::
    :class: output

    kalmanFilter with properties:

                      Label: NTREND Demo

               Observations: set
                      Prior: static
                  Estimates: set
              Uncertainties: variances

          Observation Sites: 54
        State Vector Length: 4321
           Ensemble Members: 1156
                     Priors: 1
                 Time Steps: 1262

                 Covariance:
                      Localization

                  Returning:
                      Mean
                      Variance
                      Percentiles (3)

we can see that the object will return the variance of the ensemble, as well as the 3 requested percentiles, when the object runs the Kalman filter algorithm.

.. raw:: html

    </div></section>



..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-4"><label for="lgm-4"><strong>LGM Demo</strong></label><div class="content">

In this demo, we'll return the full ensemble deviations. This is possible because we are only assimilating a single time step, so the output ensemble won't be too large. We'll use the ``deviations`` command to indicate that the algorithm should update and return the ensemble deviations::

    kf = kf.deviations(true);

Inspecting the updated object:

.. code::
    :class: input

    disp(kf)

.. code::
    :class: output

    kalmanFilter with properties:

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

                 Covariance:
                      Localization

                  Returning:
                      Mean
                      Deviations

we can see that the object will now return both the ensemble mean and deviations when running a Kalman filter.

.. raw:: html

    </div></section>



Step 5: Run the filter
----------------------
We're finally ready to run the Kalman filter algorithm. We'll do this using the ``kalmanFilter.run`` command. The base syntax for this command is::

    output = obj.run;

The output is a struct with fields for the requested outputs. These may include:

* Amean: The updated ensemble mean
* Adev: The updated ensemble deviations
* Avar: The variance of the posterior ensemble
* Aperc: Requested percentiles of the posterior ensemble

as well as other output fields.






..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-5"><label for="ntrend-5"><strong>NTREND Demo</strong></label><div class="content">

We'll use the ``run`` command to run the Kalman filter algorithm. As a reminder, the object will implement covariance localization with a localization radius of 15,000 km. Also, the algorithm should return the updated ensemble mean, ensemble variance, and ensemble quartiles for each assimilated time step::

    output = kf.run;

Examining the output:

.. code::
    :class: input

    disp(output)

.. code::
    :class: output

    struct with fields:

                 Amean: [4321×1262 single]
      calibrationRatio: [54×1262 single]
                  Avar: [4321×1262 single]
                 Aperc: [4321×3×1262 single]

we can see it includes the updated ensemble mean for each of the 1262 assimilated time steps (Amean), the ensemble variance in each time step (Avar), and the 3 ensemble quartiles in each time step (Aperc). The output also includes the calibration ratio for each proxy record in each time step.

.. raw:: html

    </div></section>



..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-5"><label for="lgm-5"><strong>LGM Demo</strong></label><div class="content">

We'll use the ``run`` command to run the Kalman filter algorithm. As a reminder, the object will implement covariance localization with a localization radius of 15,000 km. Also, the algorithm should return both the updated ensemble mean and deviations::

    output = kf.run;

Examining the output:

.. code::
    :class: input

    disp(output)

.. code::
    :class: output

    struct with fields:

                 Amean: [122880×1 double]
      calibrationRatio: [89×1 double]
                  Adev: [122880×16 double]

we can see it includes the updated ensemble mean (Amean), and the updated deviations from the ensemble mean for each ensemble member (Adev). The output also includes the calibration ratio for each proxy record in each time step.

.. raw:: html

    </div></section>



Step 6: Regrid state vector variables
-------------------------------------
At this point, you'll typically want to start mapping and visualizing the assimilation outputs. However, the assimilated variables are still organized as state vectors, which can hinder visualization. You can use the ``ensembleMetadata.regrid`` command to (1) extract a variable from a state vector, and (2) return the variable to its original data grid. The base syntax is::

    [V, metadata] = obj.regrid(variable, X)

**variable**
    The first input is the name or index of a variable in the state vector.

**X**
    The second input is a data array with a dimension that proceeds along the state vector. Most of the output fields from ``kalmanFilter.run`` use the first dimension as the state vector dimension.

**obj**
    The object is an ``ensembleMetadata`` object for the prior ensemble.

**V**
    The first output is the regridded variable. The state vector dimension will be reshaped to the original grid dimensions. All other data dimensions are left unaltered.

**metadata**
    The second output is a ``gridMetadata`` object for the regridded variable. Note that this metadata is only for the reshaped state vector dimension. Other data array dimensions (such as assimilation time steps) are not included in this metadata.


A note on tripolar grids: DASH usually represents tripolar grids as a collection of unique spatial sites. The ``regrid`` command will reshape these spatial sites into a single ``site`` dimension, so you'll often want to reshape the regridded ``site`` dimension to the size of the original tripolar output.





..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-6"><label for="ntrend-6"><strong>NTREND Demo</strong></label><div class="content">

Here, we'll regrid the updated ensemble mean of the temperature field (the **T** variable)::

    % Get the ensembleMetadata object for the prior
    ens = ensemble('ntrend');
    ens = ens.useVariables(["T", "T_index"]);
    ensMeta = ens.metadata;

    % Regrid the ensemble mean of the temperature field
    [T, metadata] = ensMeta.regrid("T", output.Amean);

Investigating the output:

.. code::
    :class: input

    siz = size(T)

.. code::
    :class: output

    siz =
             144          30        1262

we can see that the regridded output has dimensions of (longitude x latitude x assimilation time steps). The returned metadata:

.. code::
    :class: input

    disp(metadata)

.. code::
    :class: output

    gridMetadata with metadata:

      lon: [144×1 double]
      lat: [30×1 double]

includes values for the regridded lon and lat dimensions. The metadata does not include values for the third dimension, because assimilation time steps were not a dimension of the original data grid.

.. raw:: html

    </div></section>




..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-6"><label for="lgm-6"><strong>LGM Demo</strong></label><div class="content">

Here, we don't actually need to regrid the output. This is for two reasons. First, we assimilated a single state vector variable, so we don't need to extract the variable from the rest of the state vector. Second, because our variable is on a tripolar grid, the variable has a single ``site`` spatial dimension - as such, the variable would just be regridded as the current state vector. Instead, we will use Matlab's ``reshape`` command to return the tripolar grid to its original shape. Note that the original tripolar model output was organized on a 320 x 384 spatial grid::

    % Reshape the updated SST field
    SST = reshape(output.Amean, 320, 384);

We will also want to reshape the latitude and longitude metadata. We can use the ``ensembleMetadata`` object for the prior to obtain this metadata::

    % Get the latitude and longitude metadata
    ensMeta = ensemble('lgm').metadata;
    latlon = ensMeta.latlon([1 2]);

    % Reshape the metadata
    lat = reshape(latlon(:,1), 320, 384);
    lon = reshape(latlon(:,2), 320, 384);

We can now use the regridded variable and metadata with various mapping utilties.

.. raw:: html

    </div></section>




Step 7: Visualize!
------------------
That's it, the assimilation is complete! Try visualizing some of the outputs. Plotting data is outside of the scope of DASH, so use whatever mapping and visualization tools you prefer. You may be interested in:

* `Matlab's mapping toolbox <https://www.mathworks.com/help/map/index.html>`_, and
* `The m_map package <https://www.eoas.ubc.ca/~rich/map.html>`_

and there are many other resources online.


Full Demo
---------
This section recaps all the essential code from the demos and may be useful as a quick reference.


..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-full"><label for="ntrend-full"><strong>NTREND Demo</strong></label><div class="content">

::

    % Load the proxy data catalogue, and the prior ensemble/its metadata
    proxies = gridfile('ntrend');
    ens = ensemble('ntrend');
    ens = ens.useVariables(["T", "T_monthly"]);
    ensMeta = ens.metadata;

    % Create a kalman filter object
    kf = kalmanFilter("NTREND Demo");

    % Collect essential inputs
    X = ens;
    Y = proxies.load;
    % Ye    (from PSM.estimate)
    R = load('ntrend.mat','R').R;

    % Provide essential inputs to the filter
    kf = kf.prior(X);
    kf = kf.observations(Y);
    kf = kf.estimates(Ye);
    kf = kf.uncertainties(R);

    % Get localization weights
    stateCoordinates = ensMeta.latlon;
    proxyCoordinates = str2double( proxies.metadata.site(:,2:3) );
    radius = 22000;
    [wloc, yloc] = dash.localize.gc2d(stateCoordinates, proxyCoordinates, radius);

    % Add localization to the filter
    kf = kf.localize(wloc, yloc);

    % Return ensemble variance and percentiles
    percentages = [25 50 75];
    kf = kf.percentiles(percentages);
    kf = kf.variance(true);

    % Run the filter
    output = kf.run;

    % Extract and regrid variables
    [T, metadata] = ensMeta.regrid("T", output.Amean);

.. raw:: html

    </div></section>




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

    % Create a Kalman fitler object
    kf = kalmanFilter('LGM Demo');

    % Collect essential inputs
    X = ens;
    Y = proxies.load;
    % Ye     (from PSM.estimate)
    % R      (from PSM.estimate)

    % Provide essential inputs to the filter
    kf = kf.prior(ens);
    kf = kf.observations(Y);
    kf = kf.estimates(Ye);
    kf = kf.uncertainties(R);

    % Compute localization weights
    stateCoordinates = ensMeta.latlon([1 2]);
    proxyCoordinates = str2double( proxies.metadata.site(:, 2:3) );
    radius = 22000;
    [wloc, yloc] = dash.localize.gc2d(stateCoordinates, proxyCoordinates, radius);

    % Add localization to the filter
    kf = kf.localize(wloc, yloc);

    % Return the full ensemble deviations
    kf = kf.deviations(true);

    % Run the filter
    output = kf.run;

    % Reshape tripolar output
    gridSize = [320 384];
    SST = reshape(output.Amean, gridSize);
    lat = reshape(stateCoordinates(:,1), gridSize);
    lon = reshape(stateCoordinates(:,2), gridSize);

.. raw:: html

    </div></section>
