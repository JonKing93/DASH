Open Coding 3
=============

Goal
----
Use ``gridfile`` to create a data catalogue for climate proxy records.


Step 1: Create a ``.grid`` file
-------------------------------
Use the ``gridfile.new`` command to create a new, empty gridfile. The syntax of the command is as follows::

    grid = gridfile.new(filename, metadata)


**filename**
    The first input is a string listing the name of the new ``.grid`` file. If the file name does not end in a ``.grid`` extension, DASH adds the extension automatically. The file name may be an absolute or relative path - relative paths are interpreted relative to the current directory.

**metadata**
    The second input is a ``gridMetadata`` object that defines the scope of the ``gridfile`` object's N-dimensional grid. If your dataset spans multiple data source files, then this metadata should span the values for all those files.

----

**grid**
    The output is a ``gridfile`` object for the new ``.grid`` file. We can use this output to add data source files to the catalogue, load values from the dataset, and implement other tasks.

By default, the ``new`` command will not overwrite an existing gridfile. However, you can use the optional third argument to alter this behavior. Set it to ``true`` to enable overwriting::

    grid = gridfile.new(filename, metadata, true)


*Demo*
++++++
As a reminder, the demo proxy dataset consists of 54 proxy records that span most of Common Era at annual resolution. We :ref:`previously showed <demo-ntrend-metadata>` how to build a ``gridMetadata`` object for this dataset::

    % Load metadata for the proxy dataset
    proxyFile = "ntrend.mat";
    info = load(proxyFile, 'IDs', 'latitudes', 'longitudes', 'seasons', 'years');

    % Build a gridMetadata object
    site = [info.IDs, info.latitudes, info.longitudes, info.seasons];
    time = info.years;
    metadata = gridMetadata('site', site, 'time', time);

Now, we'll use the metadata object to define the scope of a new ``.grid`` file that will catalogue the proxy database. Here, we'll name the new file ``ntrend.grid``::

    % Initialize a new .grid file
    filename = "ntrend.grid";
    proxies = gridfile.new(filename, metadata);

We can inspect the new ``gridfile`` object in the console to verify that it manages the expected data catalogue:

.. code::
    :class: input

    disp(proxies);

.. code::
    :class: output

    gridfile with properties:

            File: some/path/to/Hackathon/demo/ntrend.grid
      Dimensions: site, time

      Dimension Sizes and Metadata:
          site:   54
          time: 1262    (750 to 2011)

      Data Sources: 0

Here we can see that the ``.grid`` file matches our expectations and catalogues a dataset with 54 proxy sites, and 1262 time steps (ranging from 750 CE to 2011 CE). We can also see that the new catalogue does not have any data source files associated with it yet.


.. note::
    How large is the new ``.grid`` file on your computer? Typically, these files are quite small.



Step 1b: Load existing ``gridfile``
-----------------------------------
Since they are saved to file, you can reuse ``.grid`` catalogues between different coding sessions. Use the ``gridfile`` command to return a ``gridfile`` object for an existing ``.grid`` file::

    grid = gridfile(filename)

Here, the input **filename** is the name of a ``.grid`` file on your machine. As before, the filename may be either an absolute path, or a file on the active path. The output, **grid**, is the ``gridfile`` object for the existing ``.grid`` file.

Try using the ``gridfile`` command on your new ``.grid`` file. The output ``gridfile`` object should match the object produced by the ``gridfile.new`` command.


*Demo*
++++++

We can use the ``gridfile`` command to return a ``gridfile`` object for our new proxy dataset. Here, we'll call the command on the new ``ntrend.grid`` file::

    filename = "ntrend.grid";
    proxies = gridfile(filename);

We can inspect the new ``gridfile`` in the console to verify that it matches our expectations:

.. code::
    :class: input

    disp(proxies)

.. code::
    :class: output

    gridfile with properties:

            File: some/path/to/Hackathon/demo/ntrend.grid
      Dimensions: site, time

      Dimension Sizes and Metadata:
          site:   54
          time: 1262    (750 to 2011)

      Data Sources: 0





Step 2: Add data sources
------------------------
After creating a ``.grid`` file, you can add data source files to the catalogue using the ``gridfile.add`` command. The basic syntax is::

    obj.add(type, filename, ...)

or alternatively::

    obj.add(type, opendapURL, ...)

for files accessed via OPeNDAP.

**type**
    The first input is a string that indicates the type of file being added to the catalogue. The following options are supported:

    | ``"netcdf"`` or ``"nc"``: A NetCDF file
    | ``"mat"``: A MAT-file
    | ``"text"`` or ``"txt"``: A delimited text file

**filename** / **opendapURL**
    The second input is the name of the data source file. As before, you may either use an absolute path, or the name of a file on the active path. Again, DASH will use the ``which`` command to locate files on the active path. If using OPeNDAP, then the second input should be the full OPeNDAP URL used to access the file.

.. tip::
    Remember that the **obj** preceding the ``.add`` indicates that you should use dot-indexing to add the data file to a particular ``gridfile`` object.

The ``add`` command requires at least 4 inputs, and the first two are always the file type, and the file name/OPeNDAP URL. However, the remaining inputs will vary depending on the type of file being added to the catalogue. The syntaxes for different file formats are described below.


*Delimited text files*
++++++++++++++++++++++
Delimited text files are treated as a data matrix when added to a ``.grid`` catalogue. Each new line is a row of the matrix, and each delimiter indicates a new column. The base syntax for delimited text files is::

    obj.add("text", filename, dimensions, metadata)

**dimensions**
    This input is a string vector with two elements. The first element lists the name of the ``gridfile`` dimension associated with the rows of the matrix, and the second element is the dimension associated with the columns.

    .. tip::
        The dimensions of a proxy dataset are often ``"site"`` and ``"time"``. The order of these dimensions will vary with the structure of your text file.

**metadata**
    This input is another ``gridMetadata`` object. This metadata object should list the metadata values associated with the data in the file. The metadata should include values for every dimension in the ``.grid`` catalgoue. If the proxy dataset is stored as a single data array in a single file, then **metadata** will be the same metadata object used to create the ``.grid`` file. If the file holds a subset of the full proxy dataset, then **metadata** should only have the metadata for those records.

    .. tip::
        You can use the ``gridfile.metadata`` command to return the metadata object for a ``.grid`` catalogue.

    .. tip::
        You can use ``gridMetadata.index`` to isolate the metadata for specific proxy sites.


The ``gridfile`` class also supports any options used by Matlab's ``readmatrix`` command when reading data from a text file. These options should be specified after the first four inputs. For example::

    obj.add("text", filename, dimensions, metadata, ...
            'NumHeaderLines', 3, 'Delimiter', '|');

indicates that the first 3 lines of the text file should be skipped when reading data, and that the ``|`` character should be used as a delimiter. See the documentation of the ``readmatrix`` function for a complete list of options.



*NetCDF and MAT-files*
++++++++++++++++++++++
The syntax for NetCDF and MAT-files is::

    obj.add(type, filename, variable, dimensions, metadata);

**variable**
    This input is a string listing the name of the variable in the source file that holds the relevant data.

**dimensions**
    As with text files, the **dimensions** input is a string vector that list the names of the ``gridfile`` dimensions for the variable. Unlike text files, variables in NetCDF and MAT-files may store N-dimensional arrays, so the **dimensions** input may have more than 2 dimensions. The input should list each dimension of the variable, in the order they occur.

    .. tip::
        The dimensions of a proxy dataset are often ``"site"`` and ``"time"``.

**metadata**
    This input behaves similarly as for text files. Essentially, it is a ``gridMetadata`` object that describes the scope of the data stored in the file variable. Again, we note that if the proxy dataset is stored as a single data array in a single file, then **metadata** will be the same metadata object used to create the ``.grid`` file. If the file holds a subset of the full proxy dataset, then **metadata** should only have the metadata for those records.

    .. tip::
        You can use the ``gridfile.metadata`` command to return the metadata object for a ``.grid`` catalogue.

    .. tip::
        You can use ``gridMetadata.index`` to isolate the metadata for specific proxy sites.


*Demo*
++++++
The proxy dataset for the demo is stored in the MAT-file ``ntrend.mat``. The dataset is located in the ``crn`` variable, which has dimensions of (time x site). In this example, the entire proxy dataset is located in the ``crn`` variable. Thus, we can reuse the metadata for the ``.grid`` file as the metadata for the data source file::

    % Get the gridfile and its metadata
    proxies = gridfile('ntrend.grid');
    metadata = proxies.metadata;

    % Add the data source file
    file = "ntrend.mat";
    variable = "crn";
    dimensions = ["time", "site"];
    proxies.add("mat", file, variable, dimensions, metadata)

Inspecting the gridfile in the console:

.. code::
    :class: input

    disp(proxies)

.. code::
    :class: output

      gridfile with properties:

              File: some/path/to/Hackathon/demo/ntrend.grid
        Dimensions: site, time

        Dimension Sizes and Metadata:
            site:   54
            time: 1262    (750 to 2011)

        Data Sources: 1

      Show data sources

            1. some/path/to/Hackathon/demo/ntrend.mat   Show details

we can see that the catalogue now includes the ``ntrend.mat`` data source file.



Step 3: Data adjustments
------------------------
Now we'll specify any adjustments that need to be made to our dataset. The ``gridfile`` class supports 3 main data adjustments - fill values, valid ranges, and data transformations.

*Fill value*
++++++++++++
You can use ``gridfile.fillValue`` to specify a fill value for the catalogue. When data is loaded from the catalogue, any values matching the fill value are converted to NaN. The syntax for the command is::

    obj.fillValue(value)

where **value** is the desired fill value. This syntax applies a common fill value to all data sources in the gridfile. Alternatively, you can apply a fill value to specific data sources using::

    obj.fillValue(value, sources)

where **sources** is the name or index of a data source file in the ``.grid`` catalogue.

.. tip::
    Use the ``gridfile.sources`` command to return the list of data source files for a ``.grid`` file.


*Valid Range*
+++++++++++++
You can use ``gridfile.validRange`` to specify a valid data range for the catalogue. When data is loaded, any values outside this range are converted to NaN. The syntax is::

    obj.validRange(range)

where **range** is the desired range. The **range** input should be a vector with two elements - the first element is the lower bound of the range, and the second element in the upper bound.

This syntax applies a common valid range to all data sources in the catalogue. Alternatively, you can apply a valid range to specific data sources using::

    obj.validRange(range, sources)

where **sources** is the name or index of a data source file in the ``.grid`` catalogue.

.. tip::
    Use the ``gridfile.sources`` command to return the list of data source files for a ``.grid`` file.



*Transformation*
++++++++++++++++
You can use ``gridfile.transform`` to apply a mathematical transformation to data loaded from the catalogue. ``gridfile`` currently supports the following transformations:

| Addition: ``A + X``
| Multiplication: ``A * X``
| Linear transform:  ``A + B * X``
| Exponential: ``exp(X)``
| Power: ``X^A``
| Natural log: ``ln(X)``
| Base-10 log: ``log10(X)``

The syntax for the command is::

    obj.transform(type, parameters)

where **type** is a string that lists the type of transformation. Recognized types are as follows:

| Addition: ``"add"`` or ``"plus"`` or ``"+"``
| Multiplication: ``"times"`` or ``"multiply"`` or ``"*"``
| Linear: ``"linear"``
| Exponential: ``"exp"``
| Power: ``"power"``
| Natural Log: ``"ln"`` or ``"log"``
| Base-10 Log: ``"log10"``

The second input, **parameters**, includes any mathematical parameters needed to implement the transformation. See ``dash.doc('gridfile.transform')`` for details. If a transformation does not require any parameters, you can either neglect the second input, or use an empty array.

The previous syntax will apply a common data transformation to all data sources in a catalogue. Alternatively, you can use::

    obj.transform(type, parameters, sources)

to apply different transformations to specific data source files.

.. tip::
    The ``gridfile.addAttributes`` command can be useful for recording changes to the units of a data catalogue.


*Demo*
++++++
In the demo, the proxy dataset (located in the ``crn`` variable of ``ntrend.mat``) uses a -999 fill value to indicate missing values. We'll add this fill value to the catalogue so that -999 values are converted to NaN upon load::

    proxies = gridfile("ntrend.grid");
    proxies.fillValue(-999);

Inspecting the gridfile:

.. code::
    :class: input

    disp(proxies)

.. code::
    :class: output

    proxies =

      gridfile with properties:

              File: C:/Users/jonki/Documents/Hackathon/demo/ntrend.grid
        Dimensions: site, time

        Dimension Sizes and Metadata:
            site:   54
            time: 1262    (750 to 2011)

        Fill Value: -999.000000

        Data Sources: 1

we can see it now implements a -999 fill value.




Step 4: Load data
-----------------

*Load entire catalogue*
+++++++++++++++++++++++
Now let's take a look at the ``load`` command, which is used to load data from a catalogue. The most basic syntax is::

    [X, metadata] = obj.load

which loads the entire data catalogue. Here, the **X** output is the loaded data array for the entire catalogue. The **metadata** output is a ``gridMetadata`` object for the loaded data array.

Try loading the full catalogue for your own proxy dataset. What do you see in the output?


Demo
~~~~
We can load the entire proxy dataset using::

    [X, metadata] = proxies.load;

Inspecting the output:

.. code::
    :class: input

    size(X)

.. code::
    :class: output

    ans =

              54        1262

we can see that X is a matrix with 54 rows (proxy sites), and 1262 columns (time steps). The metadata for these dimensions is provided in the **metadata** output:

.. code::
    :class: input

    disp(metadata)

.. code::
    :class: output

    gridMetadata with metadata:

      site: [54×4 string]
      time: [1262×1 double]



*Custom dimension order*
++++++++++++++++++++++++
It's often useful to load data in a specific dimension order. You can specify the order of dimensions of the loaded data using the first input::

    [X, metadata] = obj.load(dimensions)

Here, **dimensions** is a string vector that lists a requested order for loaded dimensions.

Try loading your proxy dataset with a different dimension order.

.. note::
    You don't need to list the name of every dimension in a ``.grid`` catalogue. Any unlisted data dimensions are automatically grouped at the end of the listed dimensions.


Demo
~~~~
In the previous demo, we saw that the data loaded as a (site x time) matrix. Let's instead load the data as a (time x site) matrix. We'll indicate the requested order as the first input::

    dimensions = ["time", "site"];
    [X, metadata] = obj.load(dimensions);

Inspecting the output:

.. code::
    :class: input

    size(X)

.. code::
    :class: output

    ans =

        1262          54

we can see that X is now a matrix with 1262 rows (time steps) and 54 columns (proxy sites). Note that the order of dimensions in the metadata object has likewise changed:

.. code::
    :class: input

    disp(metadata)

.. code::
    :class: output

    gridMetadata with metadata:

      time: [1262×1 double]
      site: [54×4 string]



*Data subsets*
++++++++++++++
Often, we'll only want to load a subset of the data in a catalogue. You can request a subset of data along a dimension using the second input::

   [X, metadata] = obj.load(dimensions, indices)

Here, **indices** is a cell vector with one element per listed dimension. Each element holds the requested indices along that data dimension. Loaded data will match the order of requested indices. This syntax will also load data in the listed dimension order. If you want to include a dimension in the custom order, but don't want to load a subset of that dimension, use an empty array for the dimension's indices.

.. important::
    Although you can specify data indices directly, we strongly recommend using metadata to select indices. This keeps your code more readable for other humans.


Demo
~~~~
Let's start by loading data for proxy sites NTR (site 1), TYR (site 19), and WRAx (site 3). Let's limit the data for these sites to the years 1970-1980 CE (time steps 1221-1231). Although we *could* select these indices directly::

    dimensions = [  "site", "time"];
    indices    = {[1 19 3],  1221:1231};
    [X, metadata] = proxies.load(dimensions, indices);

this is poor practice because the code does not clearly indicate what data is being loaded. Instead, we should select the indices using the gridfile's metadata::

    % Get the metadata for the catalogue
    meta = proxies.metadata;

    % Locate the requested sites
    sites = ["NTR", "TYR", "WRAx"];
    siteNames = meta.site(:,1);
    [~, siteIndices] = ismember(sites, siteNames);

    % Locate the requested time steps
    times = 1970:1980;
    timeIndices = ismember(meta.time, times);

    % Load the data
    dimensions = ["site", "time"];
    indices = {siteIndices, timeIndices};
    [X, metadata] = proxies.load(dimensions, indices);

Inspecting the output:

.. code::
    :class: input

    size(X)

.. code::
    :class: output

    ans =

         3    11

we can see that X is a matrix with 3 rows (proxy sites), and 11 columns (time steps). Investigating the returned metadata, we can see that the metadata describes a dataset with 3 proxy-site rows, and 11 time-step columns:

.. code::
    :class: input

    disp(metadata)

.. code::
    :class: output

    gridMetadata with metadata:

      site: [3x4 string]
      time: [11x1 double]

The three rows correspond to sites NTR, TYR, and WRAx (in that order):

.. code::
    :class: input

    metadata.site(:,1)

.. code::
    :class: output

    ans =

        "NTR"
        "TYR"
        "WRAx"

And the columns correspond to the years from 1970-1980 CE:

.. code::
    :class: input

    metadata.time

.. code::
    :class: output

    ans =

            1970
            1971
            1972
            ...
            1978
            1979
            1980

Now let's suppose that we want to load all time steps for the three proxy sites, and that we want the loaded data matrix to have dimensions of (time x site). Here, we can use an empty array to load all elements along the time dimension::

    dimensions = ["time", "site"];
    indices    = {[], siteIndices};
    [X, metadata] = proxies.load(dimensions, indices);

Inspecting the output:

.. code::
    :class: input

    size(X)

.. code::
    :class: output

    ans =

            1262           3

we can see that X is a (time x site) matrix with values in all 1262 time steps for the three proxy sites. We can use the returned metadata to verify the loaded data is (time x site):

.. code::
    :class: input

    disp(metadata)

.. code::
    :class: output

    gridMetadata with metadata:

      time: [1262x1 double]
      site: [3x4 string]

and that the loaded data covers the years from 750-2011 CE:

.. code::
    :class: input

    metadata.time

.. code::
    :class: output

    ans =

             750
             751
             752
             ...
            2009
            2010
            2011


Full Demo
---------
This section recaps all the essential code from the demos. You can use it as a quick reference::

    % Load metadata for the proxy dataset
    proxyFile = "ntrend.mat";
    info = load(proxyFile, 'IDs', 'latitudes', 'longitudes', 'seasons', 'years');

    % Build a gridMetadata object
    site = [info.IDs, info.latitudes, info.longitudes, info.seasons];
    time = info.years;
    metadata = gridMetadata('site', site, 'time', time);

    % Initialize a new .grid file
    filename = "ntrend.grid";
    proxies = gridfile.new(filename, metadata);

    % Add the data source file
    variable = "crn";
    dimensions = ["time", "site"];
    proxies.add("mat", proxyFile, variable, dimensions, metadata)

    % Implement a fill value
    proxies.fillValue(-999);

    % Load a subset of the catalogue in a specific dimension order
    % (all proxy sites in time steps after 1950 CE)
    order = ["time", "sites"];
    times = metadata.time > 1950;
    [X, metadata] = proxies.load(order, {times, []});
