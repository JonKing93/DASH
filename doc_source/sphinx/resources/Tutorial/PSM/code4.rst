Open Coding 4
=============

Goal
----
Use the ``PSM`` interface to generate proxy estimates.


Step 1: Download Models
-----------------------
You can use the ``PSM.download`` command to download any external forward model codes from Github. The syntax is::

    PSM.download(modelName)

where **modelName** is the name of a forward model recognized by DASH. (You can use the ``PSM.supported`` or ``PSM.info`` command to see the forward model names recognized by DASH). This command will download the codebase for the model to the current directory. You can also use the optional second input to download the model to a custom path::

    PSM.download(modelName, path)

The ``download`` command will add the downloaded code to the active Matlab path so that the code is accessible to DASH. If you close Matlab and begin a new coding session, you will need to re-add the downloaded code to your path.

The ``download`` command requires that you have (1) an internet connection, and (2) git installed on your operating system. If you don't have git installed, you can use the ``PSM.githubInfo`` command to find the location of supported forward models on Github.


..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-1"><label for="ntrend-1"><strong>NTREND Demo</strong></label><div class="content">

In this demo, we'll be using the multi-variate linear forward model. The linear model is built-in directly to DASH, so we won't need to download anything. If you still want to practice using the ``PSM.download`` command, see the LGM demo for an example using the BaySPLINE forward model.

.. raw:: html

    </div></section>





..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-1"><label for="lgm-1"><strong>LGM Demo</strong></label><div class="content">

For this demo, we'll need to download the BaySPLINE UK'37 forward model. Using the  ``PSM.info`` command:

.. code::
    :class: input

    PSM.info

.. code::
    :class: output

        Name                                     Description                                  Can_Estimate_R
    ___________    ______________________________________________________________________    ______________

    "bayfox"       "Bayesian model for d18Oc of planktic foraminifera"                           true
    "baymag"       "Bayesian model for Mg/Ca of planktic foraminifera"                           true
    "bayspar"      "Baysian model for TEX86"                                                     true
    "bayspline"    "Baysian model for UK'37"                                                     true
    "linear"       "General linear model of form:  Y = Y = a1*X1 + a2*X2 + ... an*Xn + b"        false
    "vslite"       "Vaganov-Shashkin Lite tree ring model"                                       false

we can see that DASH uses the name ``bayspline`` to identify this model. Try using the ``download`` command::

    PSM.download("vslite")

to download the code for this forward model. After running the command, your current directory should contain a folder named ``BAYSPLINE``, which holds the code for the forward model.

.. raw:: html

    </div></section>



Step 2: Create PSM Objects
--------------------------
Next, we'll need to create a PSM object for each our proxy records. To create a PSM object for a particular forward model, use::

    obj = PSM.<model name>

where **<model name>** is the name of a supported forward model. For example, the ``PSM.linear`` command creates a linear forward model object, and ``PSM.bayspar`` creates a BaySPAR forward model object. We'll refer to this command as the **constructor** for a given forward model. The inputs to the constructor are the parameters required to run the forward model for a particular proxy site. For example, the parameters of the linear forward model are the slopes and intercept of the linear model, and the parameters for the BaySPAR model are the latitude and longitude of the proxy site.

Since every model has different parameters, you should read the documentation of the constructor to determine its inputs. For example::

    help PSM.linear
    % or
    dash.doc('PSM.linear')

The DASH documentation should include a description of all required parameters, but you may find additional details in the forward model's official documentation. As a general rule, you should be familiar with a forward model prior to using it in DASH.

When building PSM objects for a group of proxies, it's typically best to organize the collection of PSM objects in a cell vector. Each element of the cell vector should hold the PSM object for a particular proxy record. Consider using the ``PSM.label`` command to apply labels to the PSM objects, as this can help clarify what each model represents.


..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-2"><label for="ntrend-2"><strong>NTREND Demo</strong></label><div class="content">

In the demo, we'll be using univariate linear forward models for the proxy records. Each forward model should be calibrated to the seasonal temperature mean for the associated proxy. Each proxy has a unique window of seasonal sensitivity, so the months used in the seasonal means will vary with the proxies. The slopes to use for the forward models are stored in the ``ntrend.mat`` file (these slopes were calculated by calibrating the proxy records against instrumental seasonal means).

Recall that the **T_monthly** variable stores the data required to run these forward models. We applied a sequence to **T_monthly** so that it stores data from each month in a given year. To run a given forward model, we'll want to locate the climate model grid point closest to the associated proxy record, extract the months of seasonal sensitivity, take the mean temperature over those months, and then apply a linear slope to that mean temperature. Since we're using a linear model, we can combine the last two steps into one. Specifically, we can divide the linear slope by the number of seasonally sensitive months (i.e. implementing a mean) and apply that slope to the temperature in each sensitive month.

Reading the documentation of the linear constructor::

    help PSM.linear

we can see that function requires the linear slopes as input. In following code, we'll create a linear PSM object for each of the 54 proxy records. We'll label each object with both the name of the proxy and the seasonally sensitive months. Finally, we'll group the set of PSM objects into a cell vector::

    % Load the parameters of the linear model
    parameters = load('ntrend.mat', 'slopes', 'intercepts');
    slopes = parameters.slopes;
    intercepts = parameters.intercepts;

    % Get the name and seasonal window for each proxy
    metadata = gridfile('ntrend').metadata;
    names = metadata.site(:,1);
    seasons = metadata.site(:,4);

    % Preallocate the cell vector for the PSM objects
    nSite = numel(names);
    models = cell(nSite, 1);

    % Loop over the proxy records. Get the months of seasonal sensitivity
    for s = 1:nSite
        months = str2num(seasons(s));
        nMonths = numel(months);

        % Get monthly slopes
        slope = slopes(s) / nMonths;
        monthlySlopes = repmat(slope, [nMonths, 1]);

        % Create a linear forward model using the slopes
        model = PSM.linear(monthlySlopes, intercepts(s));

        % Label the model and store in the cell vector
        label = strcat(names(s), " - ", seasons(s));
        model = model.label(label);
        models{s} = model;
    end

Examining the output:

.. code::
    :class: input

    disp(models)

.. code::
    :class: output

    models =
        54×1 cell array

          {1×1 PSM.linear}
          {1×1 PSM.linear}
          ...
          {1×1 PSM.linear}
          {1×1 PSM.linear}

we can see that "models" is a cell vector with 54 elements, and that each element holds a linear PSM object for a particular proxy record. We can inspect the elements of the cell to see the individual PSMs. For example:

.. code::
    :class: input

    models{1}

.. code::
    :class: output

    linear PSM with properties:

        Label: NTR - 7,8
         Rows: none

        Parameters:
           slopes: [2×1 double]
        intercept: -4.3496

we can see that the first PSM object is for the "NTR" proxy site, and that it implements a seasonal mean over July and August (months 7 and 8). Separately, the second model:

.. code::
    :class: input

    models{2}

.. code::
    :class: output

    linear PSM with properties:

        Label: GOA - 1,2,3,4,5,6,7,8,9
         Rows: none

        Parameters:
           slopes: [9×1 double]
        intercept: 0.0675

is for the "GOA" proxy site, and it implements a seasonal mean from January to September.

.. raw:: html

    </div></section>




..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-2"><label for="lgm-2"><strong>LGM Demo</strong></label><div class="content">

In this demo, we'll be using the BAYSPLINE forward model for UKL'37. Reading the documentation of its constructor::

    help PSM.bayspline

we can see the BAYSPLINE model does not require any site-specific parameteers. Thus, we can create a BAYSPLINE object for each proxy record without requiring any inputs.

In the following code, we'll create a BAYSPLINE PSM object for each of the 89 UK'37 records. We'll label each object with the name of the associated proxy record, and we'll group the set of PSM objects into a cell vector::

    % Get the ID for each proxy record
    metadata = gridfile('uk37').metadata;
    ID = metadata.site(:,1);

    % Preallocate the cell vector for the PSM objects
    nSite = numel(ID);
    models = cell(nSite, 1);

    % Build a BaySPLINE object for each proxy record
    for s = 1:nSite
        model = PSM.bayspline;

        % Label the model, and store in the cell vector
        model = model.label(ID(s));
        models{s} = model;
    end

    Examining the output:

    .. code::
        :class: input

        disp(models)

    .. code::
        :class: output

        models =

          89×1 cell array

            {1×1 PSM.bayspline}
            {1×1 PSM.bayspline}
            ...
            {1×1 PSM.bayspline}
            {1×1 PSM.bayspline}

we can see that "models" is a cell vector with 89 elements, and that each element holds a bayspline PSM object for a particular proxy record. We can inspect the elements of the cell to see the individual PSMs. For example:

.. code::
    :class: input

    models{1}

.. code::
    :class: output

    bayspline PSM with properties:

        Label: bs79-33
         Rows: none

        Parameters:
        bayes: {}

.. raw:: html

    </div></section>







Step 3: Locate Inputs in Ensemble
---------------------------------

*Specify rows*
++++++++++++++
Next, we'll need to indicate which state vector rows each forward model should use as input. The ``PSM`` interface includes a ``rows`` command, which allows you to indicate the state vector rows needed to run a given forward model. The syntax is::

    obj = obj.rows(rows)

**rows**
    The first input is a vector of indices that indicates which state vector elements are required to run the forward model.

**obj**
    The output is the updated PSM object.

If a forward model requires multiple climate variables, then the **rows** input should point to state vector elements in a specific order. For example, the BayFOX forward model requires both sea-surface temperature (SST), and δ\ :sup:`18`\ O \ :sub:`seawater` as input. When using this model, the first element of the **rows** should point to the SST variable, and the second element should point to δ\ :sup:`18`\ O \ :sub:`seawater`\ . As a rule, you should always read the documentation of a forward model's ``rows`` command before using it. For example::

    help PSM.bayspar.rows
    help PSM.linear.rows
    % or
    dash.doc('PSM.bayspar.rows')
    dash.doc('PSM.linear.rows')

Otherwise, if you pass rows in the wrong order, the forward model will mix up the input climate variables.

You can also use different state vector elements as input for different ensemble members and/or different ensembles in an evolving set. This most often occurs when implementing a deep-time assimilation with changing continental boundary conditions. See the documentation on the syntaxes::

    obj = obj.rows(memberRows)
    % and
    obj = obj.rows(evolvingRows)

for details. You can find the documentation on these syntaxes in the documentation of any forward model's ``rows`` command (for example, ``dash.doc('PSM.bayspar.rows')``), and more general information in the documentation of the PSM interface (``dash.doc('PSM.Interface.rows')``).

.. note::

    For the workshop, we've separated the discussion of the ``rows`` command from the creation of PSM objects. However, in real workflows, it's often easiest to combine these commands within the same loop.


*Locate rows*
+++++++++++++
However, before you can specify state vector elements to the ``rows`` command, you'll need to actually locate the forward model's inputs within the ensemble. The ``ensembleMetadata.closestLatLon`` command is most often used for this task, and allows you to search within a state vector variable for the data elements that are closest to a proxy record's latitude-longitude coordinates. Essentially, this allows you to locate the climate model grid point that is closest to the proxy site, within a given state vector variable. The base syntax for this command is::

    rows = obj.closestLatLon(variable, coordinates)

**obj**
    Here, obj is the ``ensembleMetadata`` object for your ensemble.

**variable**
    The first input indicates the variable in which to search. You may use either the name, or the index of a variable in the state vector.

**coordinates**
    The second input lists the coordinates of the proxy site. It should be a vector with two elements - the first element is latitude, and the second element is longitude.

**rows**
    The output is a the index of the state vector row closest to the proxy coordinates within the specified variable. If the state vector variable contains a sequence, then **rows** will be a vector, and will indicate the closest state vector row within each sequence element.


In some cases, you may have coordinate metadata stored along the ``site`` dimension (this most commonly occurs when using tripolar grids). In this case, you can use the ``'site'`` option to indicate that the command should extract coordinates from the ``site`` dimension, rather than the ``lat`` and ``lon`` dimensions. In this case, the syntax becomes::

    rows = obj.closestLatLon(variable, coordinates, 'site', columns)

**columns**
    This input is used to indicate which columns of the ``site`` metadata contain the latitude and longitude coordinates. It should be a vector with two elements. The first element is the index of the column containing latitude metadata, and the second element is the column with the longitude metadata.


----


We will only cover the ``closestLatLon`` command in the workshop, but the ``ensembleMetadata`` class includes a number of other commands which can help locate specific data elements within an ensemble. Depending on the complexity of your experiment, you may be interested in:

``ensembleMetadata.rows``
    Returns metadata down the rows of the state vector (or at queried rows) for a queried dimension.

``ensembleMetadata.variable``
    Returns metadata at the state vector rows of a queried variable.

``ensembleMetadata.find``
    Locates the state vector rows of a specific variable.

``ensembleMetadata.identify``
    Identifies the state vector variables associated with queried rows.

These functions are also helpful for locating data inputs when running forward models outside of the ``DASH`` framework.


..
    *NTREND Demo: closestLatLon*
    ++++++++++++++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-3a"><label for="ntrend-3a"><strong>NTREND Demo: closestLatLon</strong></label><div class="content">

We'll start with a quick exploration of the ``closestLatLon`` command. In the demo, we need to search through the **T_monthly** variable for data from the climate model grid point closest to each proxy record. Since **T_monthly** implements a sequence for each month of the year, the ``closestLatLon`` command should return 12 rows (one for each month of the year). We'll then select the rows that correspond to the months of the proxy's seasonal sensitivity.

Here, we'll demo the command for a single proxy record. We'll also use several ``ensembleMetadata`` commands to verify that the selected rows point to the correct data. We'll start by getting the coordinates and seasonal sensitivity window of the NTR proxy record (this is the first proxy record in our dataset):

.. code::
    :class: input

    site = gridfile('ntrend').metadata.site(1,:);
    lat = str2num(site(2))
    lon = str2num(site(3))
    season = str2num(site(4))

.. code::
    :class: output

    lat =
       65.2833

    lon =
     -161.6500

    season =
         7     8

Here we can see that the site is located at 65.28N, 161.65W, and that its seasonal window is over July and August (months 7 and 8).

Next, we'll use the ``closestLatLon`` command to locate the data elements in the **T_monthly** variable from the climate model grid point closest to this proxy site:

.. code::
    :class: input

    % Load the ensemble metadata object
    ens = ensemble('ntrend');
    ensMeta = ens.metadata;

    % Locate the closest data elements
    coordinates = [lat, lon];
    rows = ensMeta.closestLatLon("T_monthly", coordinates)

.. code::
    :class: output

    rows =

            6705
           11025
           15345
           19665
           23985
           28305
           32625
           36945
           41265
           45585
           49905
           54225

Here we can see that the command returned the indices of 12 rows within the state vector. This is because **T_monthly** includes a monthly sequence, so there are 12 rows associated with the closest climate model grid point (one per month). We can use the ``ensembleMetadata.rows`` command to verify that these rows represent the different months of the year:

.. code::
    :class: input

    timeMetadata = ensMeta.rows("time", rows)

.. code::
    :class: output

    timeMetadata =

        12×1 string array

          "Jan"
          "Feb"
          "March"
          "April"
          "May"
          "June"
          "July"
          "Aug"
          "Sept"
          "Oct"
          "Nov"
          "Dec"

at the same spatial point:

.. code::
    :class: input

    latMetadata = ensMeta.rows("lat", rows)

.. code::
    :class: output

    latMetadata =

       65.3684
       65.3684
       65.3684
       65.3684
       65.3684
       65.3684
       65.3684
       65.3684
       65.3684
       65.3684
       65.3684
       65.3684

.. code::
    :class: input

    lonMetadata = ensMeta.rows("lon", rows)

.. code::
    :class: output

    lonMetadata =

      197.5000
      197.5000
      197.5000
      197.5000
      197.5000
      197.5000
      197.5000
      197.5000
      197.5000
      197.5000
      197.5000
      197.5000

Note that you can use a mix of (-180 to 180) and (0 to 360) longitude coordinate systems in DASH. In this example, the proxy longitude uses a (-180 to 180) coordinate system, but ``closestLatLon`` still successfully locates the closest model grid point, despite the climate model longitude using a (0 to 360) coordinate system.

Now that we've verified the rows point to the correct data elements, we can use the seasonal sensitivity indices to select rows in the months of seasonal sensitivity.

.. code::
    :class: input

    rows = rows(season)

.. code::
    :class: output

    rows =
           32625
           36945


We can do a final verification to ensure that these rows represent July and August:

.. code::
    :class: input

    timeMetadata = ensMeta.rows("time", rows)

.. code::
    :class: output

    timeMetadata =

      2×1 string array

        "July"
        "August"

.. raw:: html

    </div></section>




..
    *NTREND Demo: Record rows*
    ++++++++++++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-3b"><label for="ntrend-3b"><strong>NTREND Demo: Record rows</strong></label><div class="content">

Now that we've seen how to use the ``closestLatLon`` command, we can combine it with the ``rows`` command. Here, we need to update the forward model for each proxy record, so we'll be using these commands within a ``for`` loop. Within each loop iteration, we'll locate the appropriate state vector rows for the proxy record, and then pass these rows to the forward model using the ``rows`` command::

    % Get the coordinates and metadata for each proxy site
    sites = gridfile('ntrend').metadata.site;
    lats = str2double(sites(:,2));
    lons = str2double(sites(:,3));
    seasons = sites(:,4);

    % Get the metadata object for the ensemble
    ens = ensemble('ntrend');
    ensMeta = ens.metadata;

    % Loop over the proxy sites / forward models
    for s = 1:numel(models)
        model = models{s};

        % Search for data from the closest climate model grid point
        coordinates = [lats(s), lons(s)];
        rows = ensMeta.closestLatLon("T_monthly", coordinates);

        % Select the rows for the seasonally sensitive months
        season = str2num(seasons(s));
        rows = rows(season);

        % Provide the rows to the forward model
        model = model.rows(rows);
        models{s} = model;
    end

We can double-check the forward models to ensure they know which state vector rows to use as input. For example, if we inspect the first forward model:

.. code::
    :class: input

    models{1}

.. code::
    :class: output

    linear PSM with properties:

        Label: NTR - 7,8
         Rows: set

        Parameters:
           slopes: [2×1 double]
        intercept: 0

we can see that the state vector rows have been set.

.. raw:: html

    </div></section>


..
    *LGM Demo: closestLatLon*
    +++++++++++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-3a"><label for="lgm-3a"><strong>LGM Demo: closestLatLon</strong></label><div class="content">

We'll start by exploring the ``closestLatLon`` command. In the demo, we need to search through the **SST** variable for data from the climate model grid point closest to each proxy record.

Here, we'll demo the command for a single proxy record. We'll also use several ``ensembleMetadata`` commands to verify that the selected rows point to the correct data. We'll start by getting the coordinates of the "bs79-33" proxy record (this is the first proxy record in our dataset):

.. code::
    :class: input

    site = gridfile('uk37').metadata.site(1,:);
    lat = str2num(site(2));
    lon = str2num(site(3));

.. code::
    :class: output

    lat =
       38.2617

    lon =
       14.0300

Here we can see that the site is located at 38.26N, 14.03E.

Next, we'll use the ``closestLatLon`` command to locate the data elements in the **SST** variable from the climate model grid point closest to this proxy site. Since the **SST** dataset is on a tripolar grid, it uses the ``site`` dimension to organize climate model grid points. Thus, we'll use the "site" option with this command - note that the latitude coordinate is the first column of the site metadata in ``SST.grid``, and that longitude is the second column:

.. code::
   :class: input

   % Load the ensemble metadata object
   ens = ensemble('lgm');
   ensMeta = ens.metadata;

   % Locate the closest data elements
   coordinates = [lat, lon];
   row = ensMeta.closestLatLon("SST", coordinates, 'site', [1 2])

.. code::
    :class: output

    row =
       94129

Here we can see the command returned the state vector row of the climate model grid point closest to the proxy site. We can use the ``ensembleMetadata.rows`` command to verify that this row is near the proxy site:

.. code::
    :class: input

    siteMetadata = ensMeta.rows("site", row)

.. code::
    :class: output

    siteMetadata =

       38.1033   13.7306

.. raw:: html

   </div></section>




..
   *LGM Demo: Record rows*
   +++++++++++++++++++++++

.. raw:: html

   <section class="accordion"><input type="checkbox" name="collapse" id="lgm-3b"><label for="lgm-3b"><strong>LGM Demo: Record rows</strong></label><div class="content">

Now that we've seen how to use the ``closestLatLon`` command, we can combine it with the ``rows`` command. Here, we need to update the forward model for each proxy record, so we'll be using these commands within a ``for`` loop. Within each loop iteration, we'll locate the appropriate state vector row for the proxy record, and then pass the row to the forward model using the ``rows`` command::

    % Get the coordinates for each proxy site
    site = gridfile('uk37').metadata.site;
    lats = str2double(site(:,2));
    lons = str2double(site(:,3));

    % Get the metadata object for the ensemble
    ens = ensemble('lgm');
    ensMeta = ens.metadata;

    % Loop over the proxy sites / forward models
    for s = 1:numel(models)
        model = models{s};

        % Search for the closest climate model grid point
        coordinates = [lats(s), lons(s)];
        row = ensMeta.closestLatLon("SST", coordinates, 'site', [1 2]);

        % Provide the row to the forward model
        model = model.rows(row);
        models{s} = model;
    end

We can double-check the forward models to ensure they know which state vector rows to use as input. For example, if we inspect the first forward model:

.. code::
    :class: input

    models{1}

.. code::
    :class: output

    bayspline PSM with properties:

        Label: bs79-33
         Rows: set

        Parameters:
        bayes: {}

we can see that the state vector row has been set.

.. raw:: html

    </div></section>



Step 4: Estimate Proxies
------------------------
You can run a set of forward models over an ensemble using the ``PSM.estimate`` command. Here, the base syntax is::

    [Ye, R] = PSM.estimate(models, ensemble)

**models**
    The first input is a cell vector of PSM objects. Every forward model must have its state vector rows set before running this command.

**ensemble**
    The second input is the ensemble over which to run the forward models. This input may either be a an ensemble object, or a data array (a matrix for a static ensemble, or a 3D array for an evolving ensemble).

**Ye**
    This first output is a numeric matrix that holds the proxy estimates. Each row holds the estimates for a particular proxy record, and each column holds the estimate for a particular ensemble member. If estimating proxies values for an evolving ensemble, then the output will be a 3D array with each element along the third dimension holding estimates for a particular ensemble in the evolving set.

**R**
    The second output is a numeric array that holds error-variances for the proxy estimates. This array has the same size as the **Ye** output, and the rows, columns, and pages again correspond to proxy sites, ensemble members, and ensembles in an evolving set. Not all forward models can estimate error-variances, and these models will produce NaN error-variances for the associated proxy estimates.

.. tip::

    You can use the ``PSM.info`` method to see which forward models can estimate R variances.


..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-4"><label for="ntrend-4"><strong>NTREND Demo</strong></label><div class="content">

Here, we'll run the forward models over the ensemble to produce the proxy estimates. The linear forward model does not estimate error-variances, so we'll only compute proxy estimates here::

    % Get the ensemble object
    ens = ensemble('ntrend');

    % Run the models over the ensemble
    Ye = PSM.estimate(models, ens);

Inspecting the output:

.. code::
    :class: input

    siz = size(Ye)

.. code::
    :class: output

    siz =
              54        1156

we can see that Ye is a matrix with one row for each of the 54 proxy records, and a column for each of the 1156 ensemble members.

.. raw:: html

    </div></section>



..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-4"><label for="lgm-4"><strong>LGM Demo</strong></label><div class="content">

Here, we'll run the forward models over the ensemble to produce proxy estimates. The BaySPLINE PSM is also able to estimate proxy uncertainties, so we'll also obtain those (as the second output):

    % Get the ensemble object
    ens = ensemble('lgm');

    % Run the models over the ensemble
    [Ye, R] = PSM.estimate(models, ens);

Inspecting the output:

.. code::
    :class: input

    siz = size(Ye)

.. code::
    :class: output

    siz =
       89    16

we can see that Ye is a matrix with one row for each of the 89 proxy records, and a column for each of the 16 ensemble members. Similarly examining R:

.. code::
    :class: input

    siz = size(R)

.. code::
    :class: output

    siz =
       89    16

we can see that R has an uncertainty estimate for each proxy record and ensemble member. In reality, we only want one uncertainty estimate per proxy record, so we'll use the mean uncertainty estimates over the ensemble::

    R = mean(R, 2);

.. raw:: html

    </div></section>




Full Demo
---------
This section recaps all the essential code from the demos and may be useful as a quick reference. Note that the code from several of the demo sections has been combined into a single loop.


..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-full"><label for="ntrend-full"><strong>NTREND Demo</strong></label><div class="content">

::

    % Load the linear model parameters
    parameters = load('ntrend.mat', 'slopes', 'intercepts');
    slopes = parameters.slopes;
    intercepts = parameters.intercepts;

    % Get metadata for each proxy site
    sites = gridfile('ntrend').metadata.site;
    names = sites(:,1);
    lats = str2double(sites(:,2));
    lons = str2double(sites(:,3));
    seasons = sites(:,4);

    % Get the ensemble and its metadata
    ens = ensemble('ntrend');
    ensMeta = ens.metadata;

    % Preallocate the cell vector for the PSM objects
    nSite = numel(names);
    models = cell(nSite, 1);

    % Loop over the proxy records. Get the months of seasonal sensitivity
    for s = 1:nSite
        months = str2num(seasons(s));
        nMonths = numel(months);

        % Get monthly slopes to implement a seasonal mean
        slope = slopes(s) / nMonths;
        monthlySlopes = repmat(slope, [nMonths, 1]);

        % Create a linear forward model. Label the model
        model = PSM.linear(monthlySlopes, intercepts(s));
        label = strcat(names(s), " - ", seasons(s));
        model = model.label(label);

        % Locate data from the closest climate model grid point in the months of
        % seasonal sensitivity
        coordinates = [lats(s), lons(s)];
        rows = ensMeta.closestLatLon("T_monthly", coordinates);
        rows = rows(months);

        % Record the rows and save the model
        model = model.rows(rows);
        models{s} = model;
    end

    % Run the forward models over the ensemble to produce proxy estimates
    Ye = PSM.estimate(models, ens);

.. raw:: html

    </div></section>



..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-full"><label for="lgm-full"><strong>LGM Demo</strong></label><div class="content">

::

    % Download the BaySPLINE forward model
    PSM.download('bayspline');

    % Get metadata for each proxy site
    sites = gridfile('uk37').metadata.site;
    names = sites(:,1);
    lats = str2double(sites(:,2));
    lons = str2double(sites(:,3));

    % Get the ensemble and its metadata
    ens = ensemble('lgm');
    ensMeta = ens.metadata;

    % Preallocate the cell vector for the PSM objects
    nSite = numel(names);
    models = cell(nSite, 1);

    % Loop over the proxy records and create BaySPLINE PSM objects
    for s = 1:nSite
        model = PSM.bayspline;
        model = model.label(names(s));

        % Locate data from the closest climate model grid point
        coordinates = [lats(s), lons(s)];
        row = ensMeta.closestLatLon("SST", coordinates, 'site', [1 2]);

        % Record the row and save the model
        model = model.rows(row);
        models{s} = model;
    end

    % Estimate proxy values and uncertainties
    [Ye, R] = PSM.estimate(models, ens);
    R = mean(R, 2);

.. raw:: html

    </div></section>
