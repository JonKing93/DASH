Open Coding 3
=============

Goal
----
Use the ``stateVector`` class to design and build a state vector ensemble.


Step 1: Create new state vector
-------------------------------
Use the ``stateVector`` command to create a new ``stateVector`` object::

    newObject = stateVector

where **newObject** is the new state vector object.

You can optionally label the object using the first input::

    newObject = stateVector(label)

where **label** is a string used as the label.

.. tip::
    You can also label an existing ``stateVector`` object using the ``stateVector.label`` command.

In either case, the new ``stateVector`` object will be empty. It does not yet have any variables, and so the state vector will initially have a length of zero. In the next section, we'll start adding variables to the state vector.



..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-1"><label for="ntrend-1"><strong>NTREND Demo</strong></label><div class="content">

We'll create a new ``stateVector`` object and label it as "NTREND Demo"

.. code::
    :class: input

    label = "NTREND Demo";
    sv = stateVector(label)

.. code::
    :class: output

    sv =

      stateVector with properties:

            Label: NTREND Demo
           Length: 0 rows
        Variables: 0

We can see from the console output that the state vector currently has 0 variables, and thus has a length of 0 rows.

.. raw:: html

    </div></section>



..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-1"><label for="lgm-1"><strong>LGM Demo</strong></label><div class="content">

We'll create a new ``stateVector`` object and label it as "LGM Demo"

.. code::
    :class: input

    label = "LGM Demo";
    sv = stateVector(label)

.. code::
    :class: output

    sv =

      stateVector with properties:

            Label: LGM Demo
           Length: 0 rows
        Variables: 0

We can see from the console output that the state vector currently has 0 variables, and thus has a length of 0 rows.

.. raw:: html

    </div></section>






.. _sv.add:

Step 2: Add variables
---------------------
At this point, our ``stateVector`` object does not have any variables. As :ref:`previously discussed <svv>`, a **"state vector variable"** refers to some subset of data extracted from a gridfile. Note that a state vector may include multiple variables derived from the same gridfile. Each variable is then defined by its own unique combination of indices, sequences, and means. For example, a state vector might include a spatial field, and a spatial mean derived from the same climate variable. Since the spatial field does not implement a mean, it represents a different state vector variable than the spatial mean.

Note that the definition of a state vector variable says nothing about individual climate variables - a given state vector variable may include multiple climate variables, so long as those climate variables are derived from the same gridfile. For example, a state vector variable can include multiple climate variables along the ``var`` dimension of a gridfile, although this is not required. This definition is deliberately open-ended, and it allows for flexible design of different state vectors.

In general, state vectors should include two types of variables:

1. Reconstruction targets, and
2. Climate variables required to run proxy forward models

To add a variable to a ``stateVector`` object, use the ``stateVector.add`` command. The base syntax for this command is::

    obj = obj.add(variableName, grid)

**variableName**
    The first input is a string listing the name of the new variable. The name must be a `valid Matlab variable name`_.

**grid**
    The second input indicates the gridfile that is associated with the new variable. It may either be a ``gridfile`` object, or the name of a saved ``.grid`` file. If using a file name, the name may either be an absolute file path, or the name of a file on the active path.

**obj**
    The output is the updated ``stateVector`` object.


.. _valid Matlab variable name: https://www.mathworks.com/help/matlab/matlab_prog/variable-names.html


*Multiple variables*
++++++++++++++++++++
The ``stateVector.add`` command can also be used to add multiple variables to a state vector at once. In this case, the syntax becomes::

    obj = obj.add(variableNames, grids)

where **variableNames** is a vector of names, and **grids** is a vector with one ``gridfile`` or file name per new variable. If all of the new variables are derived from the same gridfile, then **grids** may instead be a single ``gridfile`` object or file name referencing the appropriate catalogue.


..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-2"><label for="ntrend-2"><strong>NTREND Demo</strong></label><div class="content">

We'll first add reconstruction target variables to the state vector. In this demo, we'll have two reconstruction targets:

Mean summer temperature field
    Our first reconstruction target is the spatial field of mean summer temperatures. Here, we'll define "mean summer" as the mean over June, July and August (JJA). We'll only reconstruct the spatial field in the extratropical Northern Hemisphere (regions north of 35°N) because the proxy network is limited to this domain.

Spatial-mean summer temperature index
    We'll also reconstruct the spatial-mean summer temperature index. This index consists of the latitude-weighted spatial mean of the mean summer temperature field. The spatial mean is implemented over the extratropical Northern Hemisphere, and uses a JJA mean to define summer temperatures.

Both of these variables are derived from the ``temperature-cesm`` gridfile we created in the previous coding session. We'll name the mean summer temperature field as **T**, and the temperature index as **T_index**::

    % Get the variable names and associated gridfile catalogue
    variables = ["T", "T_index"];
    catalogue = 'temperature-cesm';

    % Add the variables to the state vector object
    sv = sv.add(variables, catalogue);

Inspecting the state vector:

.. code::
    :class: input

    disp(sv)

.. code::
    :class: output

    stateVector with properties:

          Label: NTREND Demo
         Length: 383533056 rows
      Variables: T, T_index
       Coupling: All variables coupled

      Vector:
                T - 191766528 rows   |   lon (144) x lat (96) x time (13872)   Show details
          T_index - 191766528 rows   |   lon (144) x lat (96) x time (13872)   Show details

we can see that the state vector now includes the two variables. At this point, the variables have extremely long state vectors. This is because all dimensions are currently set as :ref:`state dimensions <state-dims>`, so the state vector is being propagated over the very long time dimension. The variables will look more reasonable once we convert the time dimension to an ensemble dimension.

----

At this point, we still need to add state vector variables for any climate variables required to run the proxy forward models. In this demo, we will be using a univariate, linear forward model for each proxy site. Each forward model will estimate tree-ring widths using seasonal-mean temperatures from the climate model grid point closest to the proxy site. The specific seasonal mean used for each forward model will depend on the seasonal sensitivity of the associated site. (Recall that we can each site's seasonal sensitivity recorded in our proxy metadata)::

    metadata = gridfile('ntrend').metadata;
    nameSeason = metadata.site(:,[1 4]);
    disp(nameSeason)

The ``stateVector`` class is flexible, and there are a number of ways we could add the data for the forward models to our state vector. In this demo, we'll include the forward model data by adding a variable with a monthly temperature sequence - specifically, a sequence with each month of the year. This way, we will always be able to extract the necessary months for any required seasonal mean.

This approach is a good starting point, but it includes some unnecessary data in the state vector (data at any point not close to a proxy site). As a result, our approach will result in a larger overall state vector. As an alternative approach, you could instead create a variable for each proxy site, and then use the ``dash.closest.latlon`` utility to locate the climate model grid point closest to each site. You could then design each variable to only include data from that grid point - this way, the state vector would only include data strictly necessary to run the forward models. This alternative approach is thus more efficient, and can speed up later commands in the toolbox.

For now, we'll stick with our basic approach, as it's a bit easier to code. However, if you want to try the alternate approach, you will need to (1) Run the ``dash.closest.latlon`` utility, (2) Create a ``for`` loop over the proxy sites, and (3) Call the ``design`` command on each individual proxy site variable.

As mentioned, we'll include the forward model data by adding a variable with a monthly temperature sequence - specifically, a sequence with each month of the year. This way, we will always be able to extract the necessary months for any required seasonal mean. We'll name the variable for this sequence as **T_monthly** and add it to the state vector::

    variable = "T_monthly";
    catalogue = 'temperature-cesm';
    sv = sv.add(variable, catalogue);

Examining the updated object:

.. code::
    :class: input

    disp(sv)

.. code::
    :class: output

    stateVector with properties:

          Label: NTREND Demo
         Length: 575299584 rows
      Variables: T, T_index, T_monthly
       Coupling: All variables coupled

      Vector:
                  T - 191766528 rows   |   lon (144) x lat (96) x time (13872)   Show details
            T_index - 191766528 rows   |   lon (144) x lat (96) x time (13872)   Show details
          T_monthly - 191766528 rows   |   lon (144) x lat (96) x time (13872)   Show details

we can see that the "T_monthly" variable has been added to the state vector, alongside the previously added **T** and **T_index** variables.

.. raw:: html

    </div></section>





..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-2"><label for="lgm-2"><strong>LGM Demo</strong></label><div class="content">

For this demo, we'll first note that our reconstruction target is the annual mean SST field. We also note that the BaySPLINE forward models will require annual-mean SSTs as input. Thus for this demo, the reconstruction target and forward model inputs are the same variable - so we'll only need to add a single variable to the state vector. We'll name this variable **SST**. Note that the climate model output for this variable is catalogued by the ``SST.grid`` file::

    % Get the variable name and gridfile catalogue
    variable = "SST";
    grid = "SST.grid";

    % Add the variable to the state vector
    sv = sv.add(variable, grid);

Inspecting the updated state vector:

.. code::
    :class: input

    disp(sv)

.. code::
    :class: output

    stateVector with properties:

          Label: LGM Demo
         Length: 23592960 rows
      Variables: SST
       Coupling: All variables coupled

      Vector:
          SST - 23592960 rows   |   site (122880) x time (12) x run (16)   Show details

we can see that the **SST** variable has been added to the state vector. Currently, the variable is very long - this is because all dimensions are currently set as :ref:`state dimensions <state-dims>`, so the state vector is being propagated over all 16 ensemble climate model runs. Also, the time dimension currently includes elements for all 12 months, rather than an annual mean. The variable will look more reasonable once we convert the run dimension to an ensemble dimension and implement the annual mean.

.. raw:: html

    </div></section>









Step 3: Design variables
------------------------
Our next task is to design the variables in the state vector. Specifically, we need to indicate:

1. The subset of gridfile data needed for each variable, and
2. Which dimensions are ensemble dimensions

We can do both these tasks using the ``stateVector.design`` command. The base syntax for this command is::

    obj = obj.design(variables, dimensions, types)

**variables**
    The first input lists the names or indices of variables in the state vector. These are the variables that will be altered by the command. You can also use ``-1`` to select all variables in the state vector.

**dimensions**
    The second input lists the names of dimensions that should be edited.

**types**
    This input indicates whether each dimension should be set as a state dimension, or as an ensemble dimension. By default, all dimensions are initialized as state dimensions, so you will always need to select the ensemble dimensions for your variables. You can use ``1``, ``'s'``, or ``'state'`` to denote a state dimension, and ``2``, ``'e'``, ``'ens'``, or ``'ensemble'`` to denote an ensemble dimension. You can also use ``[]``, ``0``, ``'c'``, or ``'current'`` to leave a dimension in its current setting. If ``types`` lists a single option, then that option is applied to all listed dimensions. Otherwise, ``types`` should be a vector with one option per listed dimension.

**obj**
    The output is a stateVector with updated dimensions.

You can also use the option fourth input to specify the state indices or ensemble indices for each listed dimension::

    obj = obj.design(variables, dimensions, types, indices)

**indices**
    This input is a cell vector that includes the state/ensemble indices for each listed dimension. If you only listed a single dimension, you can also provide indices directly, rather than in a cell. Note that you can use an empty array ``[]`` to select all the elements along a dimension. Once again, we recommend using metadata to select indices (rather than listing indices directly) in order to improve the readability of your code.



..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-3"><label for="ntrend-3"><strong>NTREND Demo</strong></label><div class="content">

In this demo, we'll be selecting ensemble members from individual years of model output. Thus, ``time`` is our ensemble dimension. Since we only want each year to be selected once, we should choose one month to use as the reference point for each year. We'll use January as the reference month here.

We'll also use the command to limit all the variables to grid points north of 35°N. In the case of the **T** and **T_mean** variables, this is the desired reconstruction domain. For the **T_monthly** variable, we only need data from the grid points nearest to the proxy sites, and all of the proxy sites are located north of this boundary. Although limiting the domain of **T_monthly** is not strictly necessary, it will help remove unnecessary data elements from the state vector, which can help speed up later steps.

For both dimensions, we'll select indices using gridfile metadata. Also, since we're applying the same indices to all three variables, we can use the ``-1`` option to select all the variables at once::

    % Use gridfile metadata to locate January months and extratropical sites
    metadata = gridfile('temperature-cesm').metadata;
    january = month(metadata.time) == 1;
    extratropical = metadata.lat > 35;

    % Design the variables. Set time as an ensemble dimension with January as a
    % reference month. Limit the spatial domain north of 35N
    dimensions = ["time", "lat"];
    types      = ["ensemble", "state"]
    indices    = {january, extratropical}
    sv = sv.design(-1, dimensions, types, indices)

Examining the updated state vector:

.. code::
    :class: input

    disp(sv)

.. code::
    :class: output

    stateVector with properties:

          Label: NTREND Temperature Demo
         Length: 12960 rows
      Variables: T, T_index, T_monthly
       Coupling: All variables coupled

      Vector:
                  T - 4320 rows   |   lon (144) x lat (30)   Show details
            T_index - 4320 rows   |   lon (144) x lat (30)   Show details
          T_monthly - 4320 rows   |   lon (144) x lat (30)   Show details

we can see that variables are now much more reasonable lengths. This is because the time dimension has been converted to an ensemble dimension and is no longer propagated down the state vector. Also, we have removed a number of unnecessary spatial points (those points south of 35°N).

.. raw:: html

    </div></section>




..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-3"><label for="lgm-3"><strong>LGM Demo</strong></label><div class="content">

In this demo, we'll be selecting ensemble members from the 16 different climate model runs. Thus, ``run`` is our ensemble dimension. We'll use all 16 runs as ensemble members, so we don't need to restrict the dimension to a specific set of reference indices::

    % Set the "run" dimension as the ensemble dimension
    sv = sv.design("SST", "run", "ensemble");

Inspecting the updated state vector:

.. code::
    :class: input

    disp(sv)

.. code::
    :class: output

    stateVector with properties:

          Label: LGM Demo
         Length: 1474560 rows
      Variables: SST
       Coupling: All variables coupled

      Vector:
          SST - 1474560 rows   |   site (122880) x time (12)   Show details

we can see that the **SST** variable is now shorter because the ``run`` dimension has been converted to an ensemble dimension.

.. raw:: html

    </div></section>






Step 4: Implement Sequences
---------------------------
You can use the ``stateVector.sequence`` command to implement any sequences. The syntax for this command is::

    obj = obj.sequence(variables, dimension, indices, metadata)

The inputs are as follows:

**variables**
    This input should be a vector that lists either the names or indices of variables that should be given sequences. You can also use ``-1`` to select all variables in the state vector.

**dimension**
    The name of the dimension that should be given a sequence.

**indices**
    The :ref:`sequence indices <sequence-indices>` for the dimension.

**metadata**
    Metadata for each sequence index. This metadata should follow the standard rules for metadata in ``DASH``. It must be a matrix with one row per sequence index. It may have any number of columns, and the metadata must be a numeric, char, string, cellstring, or datetime data type.

You can also use the ``sequence`` command to specify a sequence for multiple dimensions at once. In this case, **dimensions** should be a string vector listing the names of the dimensions with sequences. The **indices** and **metadata** inputs should be cell vectors whose elements contain the sequence indices/metadata for the listed dimensions.


..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-4"><label for="ntrend-4"><strong>NTREND Demo</strong></label><div class="content">

In this demo, we want the **T_monthly** variable to implement a sequence such that the variable includes data for each month of the year. As a reminder, we're need this sequence so that we can implement various seasonal means for the forward models. This sequence proceeds along the ``time`` dimension. We previously specified January as a reference month, so our sequence indices will be the values from 0 to 11 (the offsets of each month from January). We'll use the names of the months (the values from 1 to 12) as the metadata::

    indices = 0:11;
    metadata = ["Jan";"Feb";"March";"April";"May";"June";"July";"Aug";"Sept";"Oct";"Nov";"Dec"];
    sv = sv.sequence("T_monthly", "time", indices, metadata);

Inspecting the updated state vector:

.. code::
    :class: input

    disp(sv);

.. code::
    :class: output

    stateVector with properties:

          Label: NTREND Demo
         Length: 60480 rows
      Variables: T, T_index, T_monthly
       Coupling: All variables coupled

      Vector:
                  T -  4320 rows   |   lon (144) x lat (30)                        Show details
            T_index -  4320 rows   |   lon (144) x lat (30)                        Show details
          T_monthly - 51840 rows   |   lon (144) x lat (30) x time sequence (12)   Show details

We can see that the **T_monthly** variable is now 12 times longer than before. This is because it now includes data for each of the 12 months of the year.

.. raw:: html

    </div></section>




..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-4"><label for="lgm-4"><strong>LGM Demo</strong></label><div class="content">

This demo doesn't require a sequence, but you might want to practice building sequences anyways. If so, try designing a sequence such that each ensemble member contains data from two consecutive climate model runs. For example::

    % Implement sequences over 2 consecutive model runs
    indices = [0 1];
    metadata = ["First run"; "Second run"];
    sv = sv.sequence('SST', 'run', indices, metadata);

Afterwards, you can delete any sequences using::

    sv = sv.sequence('SST', 'run', 'none')

.. raw:: html

    </div></section>




Step 5: Implement Means
-----------------------

You can use the ``stateVector.mean`` and ``stateVector.weightedMean`` commands to implement means in the state vector variables. The ``stateVector.mean`` command implements a basic, unweighted mean. Its syntax is::

    obj = obj.mean(variables, dimensions, indices)

The inputs are as follows:

**variables**
    A vector that lists the names or indices of variables that should be given a mean. You can also use ``-1`` to select all variables.

**dimensions**
    Should list the names of dimensions that should be given a mean. May include both state and ensemble dimensions.

**indices**
    A cell vector whose elements hold the ``LINK mean indices`` for the listed dimensions. State dimensions cannot have mean indices, so use an empty array for any state dimensions. If you only listed state dimensions, you can omit this input entirely. If you listed a single ensemble dimension, you may provide the indices directly, rather than in a cell.

You can also use the optional fourth input to specify how to treat NaN values in any mean. See ``dash.doc('stateVector.mean')`` for details.

The ``stateVector.weightedMean`` command has a similar syntax::

    obj = obj.weightedMean(variables, dimensions, weights)

**variables** and **dimensions**
    Here, the first two inputs are the same as described for the ``stateVector.mean`` method.

**weights**
    This input is a cell vector that lists the weights for the elements along each listed dimension. There should be one weight per state index (for state dimensions), or one weight per mean index (for ensemble dimensions). If you only list a single dimension, you may provide the indices directly, rather than in a cell.

Note that the ``weightedMean`` method does not allow you to specify :ref:`mean indices <mean-indices>` for ensemble dimensions. If you want to take a weighted mean over an ensemble dimension, you should:

1. Use ``stateVector.mean`` to specify the mean indices, and then
2. Use ``weightedMean`` to specify the weights for those indices.


..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-5"><label for="ntrend-5"><strong>NTREND Demo</strong></label><div class="content">

In the demo, we first need to implement a temporal mean over the **T** and **T_index** variables. Specifically, we'll need to implement a June, July, August (JJA) mean representing the summer season. The **T_index** variable should also implement a weighted spatial mean over the ``lat`` and ``lon`` dimensions. The climate model grid points in this spatial mean should be weighted by latitude to reflect the decreased area of grid points at higher latitudes.

We'll start by using the ``stateVector.mean`` command to implement the temporal mean. Since ``time`` is an ensemble dimension, we'll need to provide mean indices. Since we previously specified January as the reference month, our mean indices will be 5, 6, and 7 (the offset of the June, July, and August months from each January reference point).

Since the spatial mean is not weighted by longitude (only by latitude), we can also use the ``mean`` method to take a mean over the ``lon`` dimension. Since ``lon`` is a state dimension, we won't need any mean indices. Next, we'll calculate latitude weights, and use the ``weightedMean`` method to implement the mean over the ``lat`` dimension. Note that we should only provide weights for the state indices along the ``lat`` dimension - recall that we previously selected state indices for data elements north of 35°N::

    % Temporal mean over T and T_index
    variables = ["T", "T_index"];
    jja = [5 6 7];
    sv = sv.mean(variables, "time", jja);

    % Get the state indices along the lat dimension
    metadata = gridfile('temperature-cesm').metadata;
    extratropical = metadata.lat > 35;

    % Get the latitude weights at these indices
    latitudes = metadata.lat(extratropical);
    latitudeWeights = cosd(latitudes);

    % Latitude-weighted spatial mean
    sv = sv.mean("T_index", 'lon');
    sv = sv.weightedMean("T_index", 'lat', latitudeWeights);

Examining the updated state vector:

.. code::
    :class: input

    disp(sv)

.. code::
    :class: output

    stateVector with properties:

          Label: NTREND Demo
         Length: 56161 rows
      Variables: T, T_index, T_monthly
       Coupling: All variables coupled

      Vector:
                  T -  4320 rows   |   lon (144) x lat (30)                        Show details
            T_index -     1 rows   |   lon mean (1) x lat mean (1)                 Show details
          T_monthly - 51840 rows   |   lon (144) x lat (30) x time sequence (12)   Show details

we can see that **T_index** now implements a spatial mean. We can also follow the ``Show details`` links to display the temporal means of the **T** and **T_index** variables.

.. raw:: html

    </div></section>





..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-5"><label for="lgm-5"><strong>LGM Demo</strong></label><div class="content">

In this demo, we'll implement an annual mean over the 12 monthly climatologies. The monthly climatologies are organized along the time dimension, which is currently a state dimension. Thus, we can implement the mean directly, without needing to use any mean indices::

    % Use an annual mean
    sv = sv.mean('SST', 'time');

Inspecting the updated state vector:

.. code::
    :class: input

    disp(sv)

.. code::
    :class: output

    stateVector with properties:

          Label: LGM Demo
         Length: 122880 rows
      Variables: SST
       Coupling: All variables coupled

      Vector:
          SST - 122880 rows   |   site (122880) x time mean (1)   Show details

we can see that the SST variable now implements a temporal mean. The length of the SST variable is more reasonable now, and includes one element per spatial point on the tripolar ocean grid.

.. raw:: html

    </div></section>





Step 6: Build an ensemble
-------------------------
At this point, we're finally ready to use the ``stateVector.build`` command to generate a state vector ensemble. The base syntax for the command is::

    [X, ensMeta] = obj.build(N)

**N**
    The input is the number of ensemble members to include in the built ensemble. You can alternatively use ``'all'`` as the first input to build every ensemble member possible.

**X**
    The first output is the built state vector ensemble as a matrix. Each column is an ensemble member, and the state vector proceeds down the rows of the matrix.

**ensMeta**
    The second output is a ``ensembleMetadata`` object, which can help you locate specific data elements within the ensemble. We'll talk more about these metadata objects in a later section.

In this most basic syntax, the ``build`` command will select ensemble members at random from the reference points, and will return the built state vector ensemble directly as an array. However, there are a number of options that can modify how and where the ensemble is built. We will detail several important options here, and you can read about additional options using ``dash.doc('stateVector.build')``.

*Sequential Build*
++++++++++++++++++
You can use the ``'sequential'`` option to select ensemble members sequentially from the ensemble dimensions, rather than at random. For example, if you select ensemble members from ``time``, then using the ``'sequential'`` option will cause the ensemble members to be ordered in time. This is often useful when designing an evolving (time-dependent ensemble) because you can more easily locate specific ensemble members. Here the syntax is::

    [X, ensMeta] = obj.build(.., 'sequential', true, ..)

(where the ``..`` is the first input and any other options).


*Ensemble File*
+++++++++++++++
You can use the ``'file'`` option to save the state vector ensemble to an ensemble file. We will discuss ensemble files in the next section - for now, we'll simply note that they provide additional tools for manipulating state vector ensembles. As such, we highly recommend saving your ensembles to file. Here the syntax is::

    ens = obj.build(.., 'file', filename, ..)

**filename**
    This input is the name to use for the new ensemble file.

**ens**
    The output is an ``ensemble`` object, which allows allows you to interact with the ensemble saved in the file. We will discuss these objects in detail in the next section.

You can also combine the ``'file'`` option with the ``'overwrite'`` option, which will allow you to overwrite an existing ensemble file. To allow overwriting, use the syntax::

    ens = obj.build(..., 'file', filename, 'overwrite', true, ...)



..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-6"><label for="ntrend-6"><strong>NTREND Demo</strong></label><div class="content">

In the demo, we will build an ensemble using every possible ensemble member. We will build the ensemble sequentially, so that the ensemble members are ordered in time. We'll save the ensemble in a file named ``ntrend.ens``::

    filename = 'ntrend.ens';
    ens = sv.build('all', 'sequential', true, 'file', filename);


.. raw:: html

    </div></section>




..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-6"><label for="lgm-6"><strong>LGM Demo</strong></label><div class="content">

In this demo, we will build an ensemble using every possible ensemble member. We'll build the ensemble randomly, so each ensemble member will correspond to a random climate model run. We'll save the ensemble in a file named ``lgm.ens``::

    filename = 'lgm.ens';
    ens = sv.build('all', 'file', filename);

.. raw:: html

    </div></section>




Full Demo
---------
This section recaps all the essential code from the demos. You can use it as a quick reference.

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-full"><label for="ntrend-full"><strong>NTREND Demo</strong></label><div class="content">

::

    % Initialize a new state vector
    label = "NTREND Demo";
    sv = stateVector(label);

    % Get the temperature gridfile and its metadata
    temperature = gridfile('temperature-cesm');
    metadata = temperature.metadata;

    % Add variables
    variables = ["T", "T_index", "T_monthly"];
    sv = sv.add(variables, temperature);

    % Locate January months and spatial sites north of 35 N
    january = month(metadata.time) == 1;
    extratropical = metadata.lat > 35;

    % Make time an ensemble dimension with January reference moths.
    % Limit variables to spatial sites north of 35 N
    dimensions = ["time","lat"];
    types = ["ensemble", "state"];
    indices = {january, extratropical};
    sv = sv.design(-1, dimensions, types, indices);

    % Implement a monthly sequence
    indices = 0:11;
    sequenceMetadata = ["Jan";"Feb";"March";"April";"May";"June";"July";"Aug";"Sept";"Oct";"Nov";"Dec"];
    sv = sv.sequence("T_monthly", 'time', indices, sequenceMetadata);

    % Implement JJA temporal means
    jja = [5 6 7];
    sv = sv.mean(variables(1:2), "time", jja);

    % Implement latitude-weighted spatial mean
    lats = metadata.lat(extratropical);
    weights = cosd(lats);
    sv = sv.mean("T_index", 'lon');
    sv = sv.weightedMean("T_index", 'lat', weights);

    % Build ensemble sequentially and save to file
    filename = 'ntrend.ens';
    ens = sv.build('all', 'sequential', true, 'file', filename);

.. raw:: html

    </div></section>




.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-full"><label for="lgm-full"><strong>LGM Demo</strong></label><div class="content">

::

    % Initialize a new state vector
    label = "LGM Demo";
    sv = stateVector(label);

    % Add the SST variable
    variable = "SST";
    catalogue = "SST.grid";
    sv = sv.add(variable, catalogue);

    % Set "run" as an ensemble dimension
    sv = sv.design('SST', 'run', 'ensemble');

    % Implement an annual average
    sv = sv.mean('SST', 'time');

    % Build a state vector ensemble and save it to file
    filename = 'lgm.ens';
    sv.build('all', 'file', filename);

.. raw:: html

    </div></section>
