Coding 3
========

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

**grid**
    The output is a ``gridfile`` object for the new ``.grid`` file. We can use this output to add data source files to the catalogue, load values from the dataset, and implement other tasks.

By default, the ``new`` command will not overwrite an existing gridfile. However, you can use the optional third argument to alter this behavior. Set it to ``true`` to enable overwriting::

    grid = gridfile.new(filename, metadata, true)






..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-1a"><label for="ntrend-1a"><strong>NTREND Demo: Proxy Records</strong></label><div class="content">

As a reminder, the demo proxy dataset consists of 54 proxy records that span most of Common Era at annual resolution. We :ref:`previously showed <gridMetadata-full-demo>` how to build a ``gridMetadata`` object for this dataset::

    % Load metadata fields from the proxy records file
    contents = load('ntrend.mat');
    IDs = contents.IDs;
    lats = contents.latitudes;
    lons = contents.longitudes;
    years = contents.years;
    seasons = contents.seasons;

    % Combine IDs, lats, and lons into "site" metadata
    site = [IDs, lats, lons, seasons];

    % Create the metadata object
    proxyMetadata = gridMetadata('site', site, 'time', years);

    % Add metadata attributes
    name = 'site_metadata_columns';
    columns = ["ID", "Latitude", "Longitude", "Season"];
    proxyMetadata = proxyMetadata.addAttributes(name, columns);

Now, we'll use the metadata object to define the scope of a new ``.grid`` file that will catalogue the proxy database. Here, we'll name the new file ``ntrend.grid``::

    % Initialize a new .grid file
    filename = "ntrend.grid";
    proxies = gridfile.new(filename, proxyMetadata);

We can inspect the new ``gridfile`` object in the console to verify that it manages the expected data catalogue:

.. code::
    :class: input

    disp(proxies);

.. code::
    :class: output

    gridfile with properties:

            File: path/to/tutorial/demos/ntrend.grid
      Dimensions: site, time

      Dimension Sizes and Metadata:
          site:   54
          time: 1262    (750 to 2011)

      Attributes:
          site_metadata_columns: ["ID"    "Latitude"    "Longitude"    "Season"]

      Data Sources: 0

Here we can see that the ``.grid`` file matches our expectations and catalogues a dataset with 54 proxy sites, and 1262 time steps (ranging from 750 CE to 2011 CE). We can also see that the new catalogue does not have any data source files associated with it yet.

.. raw:: html

    </div></section>



..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-1b"><label for="ntrend-1b"><strong>NTREND Demo: Climate Model Outputs</strong></label><div class="content">

Next, we'll create a gridfile for the climate model output. We previously showed how to build a metadata object for this dataset::

    % Use NetCDF metadata for lat and lon
    file = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.185001-200512.nc';
    lat = ncread(file, 'lat');
    lon = ncread(file, 'lon');

    % Create time metadata
    time = datetime(850,1,1) : calmonths(1) : datetime(2005,12,1);
    time = time';

    % Create the metadata object
    modelMetadata = gridMetadata('lat', lat, 'lon', lon, 'time', time);

    % Add Attributes
    modelMetadata = modelMetadata.addAttributes("Model", "CESM 1.0", "raw_units", "Kelvin");

Now, we'll use the metadata object to define the scope of a new ``.grid`` file that will catalogue the output temperature field from the climate model. Here, we'll name the new file ``temperature-cesm.grid``::

    file = "temperature-cesm";
    grid = gridfile.new(file, modelMetadata);

We can inspect the new gridfile in the console to check that it matches our expectations:

.. code::
    :class: input

    disp(grid)

.. code::
    :class: output

    gridfile with properties:

            File: path/to/tutorial/demos/temperature-cesm.grid
      Dimensions: lon, lat, time

      Dimension Sizes and Metadata:
           lon:   144    (          0 to 357.5      )
           lat:    96    (        -90 to 90         )
          time: 13872    (01-Jan-0850 to 01-Dec-2005)

      Attributes:
              Model: "CESM 1.0"
          raw_units: "Kelvin"

      Data Sources: 0

Here we can see that the ``.grid`` file matches our expectations and catalogues a dataset for a global temperature field that ranges from 850-2005 CE. We can also see that the new catalogue does not have any data source files associated with it yet.

.. raw:: html

    </div></section>




..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-1a"><label for="lgm-1a"><strong>LGM Demo: Proxy Records</strong></label><div class="content">

Here, we'll create a gridfile data catalogue for our proxy records. We previously discussed how to build a metadata object for this dataset::

    % Load the metadata
    contents = load('UK37.mat');
    IDs = contents.ID;
    lats = contents.lat;
    lons = contents.lon;
    time = contents.time;

    % Combine IDs, lats, and lons into "site" metadata
    site = [IDs, lats, lons];

    % Create the metadata object
    proxyMetadata = gridMetadata('site', site, 'time', time);
    proxyMetadata = proxyMetadata.addAttributes("time_units", "ka", "type", "UK'37", ...
                             'site_metadata_columns', ["ID","Latitude","Longitude"]);

We'll use this metadata to define the scope of a new ``.grid`` file that will catalogue these proxy records. We'll name the new file ``UK37.grid``:

.. code::
    :class: input

    file = 'UK37.grid';
    grid = gridfile.new(file, proxyMetadata)

.. code::
    :class: output

    gridfile with properties:

            File: path/to/tutorial/demos/UK37.grid
      Dimensions: site, time

      Dimension Sizes and Metadata:
          site: 89
          time:  1

      Attributes:
                     time_units: "ka"
                           type: "UK'37"
          site_metadata_columns: ["ID"    "Latitude"    "Longitude"]

      Data Sources: 0

We can see that the file ``UK37.grid`` manages a data catalogue for the 89 proxy sites during a single time step.

.. raw:: html

    </div></section>




..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-1b"><label for="lgm-1b"><strong>LGM Demo: Climate Model Output</strong></label><div class="content">

Here, we'll create a gridfile data catalogue for the climate model output. We previously discussed how to create a metadata object for this data set::

    % Get the file metadata
    contents = load('SST.mat');
    lat = contents.lat;
    lon = contents.lon;
    time = contents.month;
    run = contents.run;

    % Reshape tripolar metadata
    site = [lat(:), lon(:)];

    % Build metadata object
    modelMetadata = gridMetadata('site', site, 'time', time, 'run', run)

    % Add attributes
    model = "iCESM";
    units = "Celsius";
    time = "18-21 ka";
    columns = ["Latitude", "Longitude"];
    modelMetadata = modelMetadata.addAttributes("Model", model, "Units", units, ...
        "time_span", time, "site_metadata_columns", columns);

We'll use this metadata to define the scope of a new gridfile for the climate model output. We'll name the new file ``SST.grid``:

.. code::
    :class: input

    file = "SST";
    grid = gridfile.new(file, modelMetadata)

.. code::
    :class: output

    gridfile with properties:

            File: path/to/tutorial/demos/SST.grid
      Dimensions: site, time, run

      Dimension Sizes and Metadata:
          site: 122880
          time:     12    (Jan to Dec)
           run:     16    (  1 to 16 )

      Attributes:
                          Model: "iCESM"
                          Units: "Celsius"
                      time_span: "18-21 ka"
          site_metadata_columns: ["Latitude"    "Longitude"]

      Data Sources: 0

Here, we can see that the new file manages a data catalogue for 122880 spatial sites. The catalogue includes data for 12 monthly climatologies, and data from 16 climate model runs. We can also see that the new file does not yet have any data sources associated with it.

.. raw:: html

    </div></section>





Step 2: Load existing ``gridfile``
-----------------------------------
Since they are saved to file, you can reuse ``.grid`` catalogues between different coding sessions. Use the ``gridfile`` command to return a ``gridfile`` object for an existing ``.grid`` file::

    grid = gridfile(filename)

Here, the input **filename** is the name of a ``.grid`` file on your machine. As before, the filename may be either an absolute path, or a file on the active path. The output, **grid**, is the ``gridfile`` object for the existing ``.grid`` file.

Try using the ``gridfile`` command on your new ``.grid`` file. The output ``gridfile`` object should match the object produced by the ``gridfile.new`` command.





..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-2"><label for="ntrend-2"><strong>NTREND Demo</strong></label><div class="content">

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

            File: path/to/tutorial/demos/ntrend.grid
      Dimensions: site, time

      Dimension Sizes and Metadata:
          site:   54
          time: 1262    (750 to 2011)

      Attributes:
          site_metadata_columns: ["ID"    "Latitude"    "Longitude"    "Season"]

      Data Sources: 0

.. raw:: html

  </div></section>


..
  *LGM Demo*
  +++++++++++++

.. raw:: html

  <section class="accordion"><input type="checkbox" name="collapse" id="lgm-2"><label for="lgm-2"><strong>LGM Demo</strong></label><div class="content">

We can use the ``gridfile`` command to load a gridfile object for our climate model dataset::

    grid = gridfile('SST');

We can inspect the output gridfile object to ensure that it matches our expectations:

.. code::
    :class: input

    disp(grid)

.. code::
    :class: output

    gridfile with properties:

            File: path/to/tutorial/demos/SST.grid
      Dimensions: site, time, run

      Dimension Sizes and Metadata:
          site: 122880
          time:     12    (Jan to Dec)
           run:     16    (  1 to 16 )

      Attributes:
                          Model: "iCESM"
                          Units: "Celsius"
                      time_span: "18-21 ka"
          site_metadata_columns: ["Latitude"    "Longitude"]

      Data Sources: 0

.. raw:: html

  </div></section>



Step 3: Add data sources
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
    | ``"text"`` or ``"txt"``: A delimited text file (such as a .csv file)

**filename** / **opendapURL**
    The second input is the name of the data source file. As before, you may either use an absolute path, or the name of a file on the active path. If using OPeNDAP, then the second input should be the full OPeNDAP URL used to access the file.

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
        You can use ``gridMetadata.index`` to isolate the metadata for specific data files.


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

**metadata**
    This input behaves similarly as for text files. Essentially, it is a ``gridMetadata`` object that describes the scope of the data stored in the file variable. Again, we note that if the proxy dataset is stored as a single data array in a single file, then **metadata** will be the same metadata object used to create the ``.grid`` file. If the file holds a subset of the full proxy dataset, then **metadata** should only have the metadata for those records.

    .. tip::
        You can use the ``gridfile.metadata`` command to return the metadata object for a ``.grid`` catalogue.

    .. tip::
        You can use ``gridMetadata.index`` to isolate the metadata for specific data files.






..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-3a"><label for="ntrend-3a"><strong>NTREND Demo: Proxy Records</strong></label><div class="content">

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

            File: path/to/tutorial/demos/ntrend.grid
      Dimensions: site, time

      Dimension Sizes and Metadata:
          site:   54
          time: 1262    (750 to 2011)

      Attributes:
          site_metadata_columns: ["ID"    "Latitude"    "Longitude"    "Season"]

      Data Sources: 1

    Show data sources

          1. path/to/tutorial/demos/ntrend.mat   Show details

we can see that the catalogue now includes the ``ntrend.mat`` data source file.

.. raw:: html

    </div></section>



..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-3b"><label for="ntrend-3b"><strong>NTREND Demo: Climate Model Output</strong></label><div class="content">

The temperature output from the climate model is located in two NetCDF files.  In both files, the associated temperature data is stored in a variable named ``TREFHT``. The ``TREFHT`` variable is organized as (``lon`` x ``lat`` x ``time``). The first file contains outputs from 850 CE to 1849 CE (the pre-industrial period), and the second file contains temperatures from 1850 CE to 2005 CE (post-industrial). We will use the ``gridMetadata.index`` command to return the metadata for each data source file, and then catalogue the file::

    % Get the output files, variable name, and dimensions
    file1 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.085001-184912.nc';
    file2 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.185001-200512.nc';
    variable = "TREFHT";
    dimensions = ["lon", "lat", "time"];

    % Get the gridfile and its metadata
    temperature = gridfile('temperature-cesm.grid');
    metadata = temperature.metadata;

    % Get the metadata for the first file and add to the catalogue
    preindustrial = year(metadata.time) < 1850;
    metadata1 = metadata.index('time', preindustrial);
    temperature.add('netcdf', file1, variable, dimensions, metadata1);

    % Get metadata for the second file and add to the catalogue
    postindustrial = year(metadata.time) >= 1850;
    metadata2 = metadata.index('time', postindustrial);
    temperature.add('netcdf', file2, variable, dimensions, metadata2);

Examining the gridfile:

.. code::
    :class: input

    disp(temperature)

.. code::
    :class: output

    gridfile with properties:

            File: path/to/tutorial/demos/temperature-cesm.grid
      Dimensions: lon, lat, time

      Dimension Sizes and Metadata:
           lon:   144    (          0 to 357.5      )
           lat:    96    (        -90 to 90         )
          time: 13872    (01-Jan-0850 to 01-Dec-2005)

      Attributes:
              Model: "CESM 1.0"
          raw_units: "Kelvin"

      Data Sources: 2

    Show data sources

          1. path/to/tutorial/demos/b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.085001-184912.nc   Show details
          2. path/to/tutorial/demos/b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.185001-200512.nc   Show details

we can see it now catalogues data for the two NetCDF data sources.

.. raw:: html

    </div></section>




..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-3a"><label for="lgm-3a"><strong>LGM Demo: Proxy Records</strong></label><div class="content">

The proxy dataset for the demo is stored in the MAT-file ``UK37.mat``. The dataset is located in the ``Y`` variable, which has dimensions of (time x site). In this example, the entire proxy dataset is located in the ``Y`` variable. Thus, we can reuse the metadata for the ``.grid`` file as the metadata for the data source file::

    % Get the gridfile and its metadata
    proxies = gridfile('UK37.grid');
    metadata = proxies.metadata;

    % Add the data source file
    file = "UK37.mat";
    variable = "Y";
    dimensions = ["time", "site"];
    proxies.add("mat", file, variable, dimensions, metadata)

Inspecting the gridfile in the console:

.. code::
    :class: input

    disp(proxies)

.. code::
    :class: output

    gridfile with properties:

            File: C:/Users/jonki/Documents/Hackathon/demos/tutorial/UK37.grid
      Dimensions: site, time

      Dimension Sizes and Metadata:
          site: 89
          time:  1

      Attributes:
                     time_units: "ka"
                           type: "UK'37"
          site_metadata_columns: ["ID"    "Latitude"    "Longitude"]

      Data Sources: 1

    Show data sources

          1. C:/Users/jonki/Documents/Hackathon/demos/tutorial/UK37.mat   Show details

we can see it now catalogues data in the ``UK37.mat`` data source file.

.. raw:: html

    </div></section>




Aside: Merging Dimensions
-------------------------
In some cases, the data in a data source file may have more dimensions than the gridfile. This can occur when two or more dimensions of the raw data are combined into a single dimension in DASH.

This situation is common when working with tripolar model output. As mentioned, tripolar output describes a collection of unique spatial sites, but the output is often reported on a "latitude x longitude" array. In the demos, we saw that we could create a metadata object for a tripolar field by combining the latitude and longitude metadata into a single ``site`` dimension.

When such a situation occurs, you will need to indicate which dimensions of the raw data are being combined into a single dimension. We will refer to this process as **merging** dimensions. You can use the ``dimensions`` input of the ``gridfile.add`` command to merge dimensions. To do so, use the name of the new dimension for each of the raw, merged dimensions in the list. Continuing the tripolar example, you would use ``"site"`` as the name of the dimension for both the ``"lat"`` and ``"lon"`` dimensions of the raw data.




..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-3b"><label for="lgm-3b"><strong>LGM Demo: Climate Model Output</strong></label><div class="content">

The climate model output is stored in the file ``SST.mat`` in the ``SST`` variable. This variable has dimensions of (lat x lon x time x run), but we want to merge the ``lat`` and ``lon`` dimension into a single ``site`` dimension. In this example, the entire climate model output is located in the ``SST.mat`` file, so we can reuse the metadata for the entire gridfile as the metadata object for the file::

    % Get the gridfile and its metadata
    sst = gridfile('SST');
    metadata = sst.metadata;

    % Add the data source file
    file = "SST.mat";
    variable = "SST";
    dimensions = ["site", "site", "time", "run"];
    sst.add("mat", file, variable, dimensions, metadata);

Inspecting the gridfile:

.. code::
    :class: input

    disp(sst)

.. code::
    :class: output

    gridfile with properties:

            File: path/to/tutorial/demos/SST.grid
      Dimensions: site, time, run

      Dimension Sizes and Metadata:
          site: 122880
          time:     12    (Jan to Dec)
           run:     16    (  1 to 16 )

      Attributes:
                          Model: "iCESM"
                          Units: "Celsius"
                      time_span: "18-21 ka"
          site_metadata_columns: ["Latitude"    "Longitude"]

      Data Sources: 1

    Show data sources

          1. path/to/tutorial/demos/SST.mat   Show details

we can see the catalogue now uses ``SST.mat`` as a data source file.

.. raw:: html

    </div></section>



Step 4: Data adjustments
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


..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-4a"><label for="ntrend-4a"><strong>NTREND Demo: Fill Value</strong></label><div class="content">

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

.. raw:: html

    </div></section>



..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-4b"><label for="ntrend-4b"><strong>NTREND Demo: Transform</strong></label><div class="content">

In the demo, our climate model temperature output is provided in units of Kelvin. However, we'd prefer to use units of Celsius, so we'll apply a data transformation to convert Kelvin to Celsius::

    % Add the data conversion
    temperature = gridfile("temperature-cesm.grid");
    temperature.transform("plus", -273.15);

    % Note the conversion in the metadata attributes
    temperature.addAttributes("converted_units", "Celsius");

Examining the gridfile:

.. code::
    :class: input

    disp(temperature)

.. code::
    :class: output

    gridfile with properties:

            File: path/to/Hackathon/demo/temperature-cesm.grid
      Dimensions: lon, lat, time

      Dimension Sizes and Metadata:
           lon:   144    (          0 to 357.5      )
           lat:    96    (        -90 to 90         )
          time: 13872    (15-Jan-0850 to 15-Dec-2005)

      Attributes:
                    Units: "Kelvin"
                    Model: "CESM 1.0"
          converted_units: "Celsius"

      Transform: X + -273.150000

      Data Sources: 2

we can see that loaded values will be converted from Kelvin to Celsius.

.. raw:: html

    </div></section>








Step 5: Load data
-----------------

*Load entire catalogue*
+++++++++++++++++++++++
Now let's take a look at the ``load`` command, which is used to load data from a catalogue. The most basic syntax is::

    [X, metadata] = obj.load

which loads the entire data catalogue. Here, the **X** output is the loaded data array for the entire catalogue. The **metadata** output is a ``gridMetadata`` object for the loaded data array.



..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-5a"><label for="ntrend-5a"><strong>NTREND Demo</strong></label><div class="content">

We can load the entire proxy dataset using::

    proxies = gridfile('ntrend');
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

.. raw:: html

  </div></section>


..
  *LGM Demo*
  +++++++++++++

.. raw:: html

  <section class="accordion"><input type="checkbox" name="collapse" id="lgm-5a"><label for="lgm-5a"><strong>LGM Demo</strong></label><div class="content">

We can load the entire proxy dataset using::

    proxies = gridfile('UK37');
    [Y, metadata] = proxies.load;

Inspecting the output:

.. code::
    :class: input

    siz = size(Y)

.. code::
    :class: output

    siz =
        89     1

we can see that **Y** is a matrix with 89 rows (proxy sites), and one column (time step). The metadata for these dimensions is provided in the **metadata** output:

.. code::
    :class: input

    disp(metadata)

.. code::
    :class: output

    gridMetadata with metadata:

            site: [89×3 string]
            time: [18.001 21]
      attributes: [1×1 struct]

.. raw:: html

  </div></section>



*Custom dimension order*
++++++++++++++++++++++++
It's often useful to load data in a specific dimension order. You can specify the order of dimensions of the loaded data using the first input::

    [X, metadata] = obj.load(dimensions)

Here, **dimensions** is a string vector that lists a requested order for loaded dimensions.

Try loading your proxy dataset with a different dimension order.

.. note::
    You don't need to list the name of every dimension in a ``.grid`` catalogue. Any unlisted data dimensions are automatically grouped at the end of the listed dimensions.




..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-5b"><label for="ntrend-5b"><strong>NTREND Demo</strong></label><div class="content">

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

.. raw:: html

  </div></section>



*Data subsets*
++++++++++++++
Often, we'll only want to load a subset of the data in a catalogue. You can request a subset of data along a dimension using the second input::

   [X, metadata] = obj.load(dimensions, indices)

Here, **indices** is a cell vector with one element per listed dimension. Each element holds the requested indices along that data dimension. Loaded data will match the order of requested indices. This syntax will also load data in the listed dimension order. If you want to include a dimension in the custom order, but don't want to load a subset of that dimension, use an empty array for the dimension's indices.

.. important::
    Although you can specify data indices directly, we strongly recommend using metadata to select indices. This keeps your code more readable.




..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-5c"><label for="ntrend-5c"><strong>NTREND Demo</strong></label><div class="content">

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

.. raw:: html

    </div></section>



Full Demo
---------
This section recaps all the essential code from the demos. You can use it as a quick reference:

..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-fa"><label for="ntrend-fa"><strong>NTREND Demo: Proxy Records</strong></label><div class="content">

::

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
    order = ["time", "site"];
    times = metadata.time > 1950;
    [X, metadata] = proxies.load(order, {times, []});

.. raw:: html

    </div></section>



..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-fb"><label for="ntrend-fb"><strong>NTREND Demo: Climate Model Output</strong></label><div class="content">

::

    % Get the output files
    outputFile1 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.085001-184912.nc';
    outputFile2 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.185001-200512.nc';

    % Define metadata that spans the climate model output dataset
    lat = ncread(outputFile1, 'lat');
    lon = ncread(outputFile1, 'lon');
    time = datetime(850,1,15):calmonths(1):datetime(2005,12,15);

    % Create a metadata object
    metadata = gridMetadata("lat", lat, "lon", lon, "time", time');
    metadata = metadata.addAttributes("raw_units", "Kelvin", "Model", "CESM 1.0");

    % Use the metadata to initialize a new gridfile catalogue
    file = "temperature-cesm.grid";
    temperature = gridfile.new(file, metadata);

    % Get the name and dimensions of the data variable in the output files
    variable = "TREFHT";
    dimensions = ["lon", "lat", "time"];

    % Add the first output file to the catalogue
    preindustrial = year(metadata.time) < 1850;
    metadata1 = metadata.index('time', preindustrial)
    temperature.add('netcdf', outputFile1, variable, dimensions, metadata1);

    % Get metadata for the second file and add to the catalogue
    postindustrial = year(metadata.time) >= 1850;
    metadata2 = metadata.index('time', postindustrial);
    temperature.add('netcdf', outputFile2, variable, dimensions, metadata2);

    % Apply a conversion from Kelvin to Celsius. Record the conversion
    temperature.transform('plus', -273.15);
    temperature.addAttributes('converted_units', 'Celsius');

    % Load a subset of the catalogue
    % (Northern Hemisphere, pre-1850 in a time x lon x lat order)
    nh = metadata.lat > 0;
    preindustrial = year(metadata.time) < 1850;
    order = ["time", "lon", "lat"];
    indices = {preindustrial, [], nh};
    [X, metadata] = temperature.load(order, indices);

.. raw:: html

    </div></section>


..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-fa"><label for="lgm-fa"><strong>LGM Demo: Proxy Records</strong></label><div class="content">

::

    % Load the metadata
    contents = load('UK37.mat');
    IDs = contents.ID;
    lats = contents.lat;
    lons = contents.lon;
    time = contents.time;

    % Combine IDs, lats, and lons into "site" metadata
    site = [IDs, lats, lons];

    % Create the metadata object
    proxyMetadata = gridMetadata('site', site, 'time', time);
    proxyMetadata = proxyMetadata.addAttributes("time_units", "ka", "type", "UK'37", ...
                             'site_metadata_columns', ["ID","Latitude","Longitude"]);

    % Initialize a new gridfile
    file = 'UK37.grid';
    proxies = gridfile.new(file, proxyMetadata);

    % Add data source file
    file = "UK37.mat";
    variable = "Y";
    dimensions = ["time", "site"];
    metadata = proxies.metadata;
    proxies.add("mat", file, variable, dimensions, metadata);

    % Load the catalogue
    [X, metadata] = proxies.load;

.. raw:: html

    </div></section>


..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-fb"><label for="lgm-fb"><strong>LGM Demo: Climate Model Output</strong></label><div class="content">

::

    % Get the file metadata
    contents = load('SST.mat');
    lat = contents.lat;
    lon = contents.lon;
    time = contents.month;
    run = contents.run;

    % Reshape tripolar metadata
    site = [lat(:), lon(:)];

    % Build metadata object
    metadata = gridMetadata('site', site, 'time', time, 'run', run)
    metadata = metadata.addAttributes("Model", "iCESM", "Units", ...
        "Celsius", "time_span", "18-21 ka", "site_metadata_columns", ["Latitude", "Longitude"]);

    % Initialize a new gridfile
    file = "SST.grid";
    sst = gridfile.new(file, metadata);

    % Add data source file
    file = "SST.mat";
    variable = "SST";
    dimensions = ["site","site","time","run"];
    sst.add("mat", file, variable, dimensions, metadata);

    % Load the catalogue
    [SST, metadata] = sst.load;

.. raw:: html

    </div></section>
