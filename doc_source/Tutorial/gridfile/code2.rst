Coding 2
========

Goal
----
Use ``gridMetadata`` to create metadata objects for the demo datasets.



Step 1: Create metadata objects
-------------------------------
You can use the ``gridMetadata`` command to create a metadata object. The inputs to this command are a series of (Dimension-Name, Metadata-Values) pairs. The output is the new metadata object. Overall the syntax is::

    metadataObject = gridMetadata(name1, values1, .., nameN, valuesN)

**names**
    Each dimension name should be a string scalar, and you cannot repeat dimensions.

**values**
    The metadata value for each dimension should be a matrix with one row per element along the dimension. The matrix may have any number of columns, and may be a numeric, char, string, cellstring, logical, or datetime data type. The matrix may not include NaN, NaT, or <missing> elements.

**metadataObject**
    The output is the metadata object for the dataset.

Try using this command to create metadata objects for the demo datasets.


**NTREND Demo: Proxy Records**
++++++++++++++++++++++++++++++
We'll start by creating a metadata object for the proxy record dataset. As a reminder, the proxy dataset consists of 54 tree ring records (proxy sites), and spans the interval from 750-2011 CE. The dataset is stored in the downloaded file ``ntrend.mat``.

This dataset consists of various proxy sites over time, so we will want to define metadata for the ``site`` and ``time`` dimensions. If we load the contents of the ``ntrend.mat`` file:

.. code::
    :class: input

    contents = load('ntrend.mat')

.. code::
    :class: output

    contents =

      struct with fields:

               IDs: [54×1 string]
                 R: [54×1 double]
               crn: [1262×54 double]
        intercepts: [54×1 double]
         latitudes: [54×1 string]
        longitudes: [54×1 string]
           seasons: [54×1 string]
            slopes: [54×1 double]
             years: [1262×1 double]

we can see that the file already contains a number of metadata fields. Some key fields include the ID of each proxy site (IDs), the coordinates of each site (latitudes and longitudes), and the years of the dataset (years). We'll use these values to create a metadata object for the dataset. (Don't worry, we'll return to the R, crn, slopes, and intercepts variables later in the tutorial).

We'll note that the IDs, latitudes, and longitudes all pertain to the proxy sites, so we'll combine them to create metadata for the ``site`` dimension. We'll use the years as metadata for the ``time`` dimension::

    % Load metadata fields from the proxy records file
    contents = load('ntrend.mat');
    IDs = contents.IDs;
    lats = contents.latitudes;
    lons = contents.longitudes;
    years = contents.years;

    % Combine IDs, lats, and lons into "site" metadata
    site = [IDs, lats, lons];

    % Create the metadata object
    proxyMetadata = gridMetadata('site', site, 'time', years);

Inspecting the metadata object:

.. code::
    :class: input

    disp(proxyMetadata)

.. code::
    :class: output

    gridMetadata with metadata:

      site: [54×3 string]
      time: [1262×1 double]

we can see that it includes metadata for the ``site`` and ``time`` dimensions.


**LGM Demo: Proxy Records**
+++++++++++++++++++++++++++
Here we'll create a metadata object for the LGM proxy dataset. As a reminder, this dataset consists of 89 Uk'37 records at the LGM. The dataset is stored in the downloaded file ``UK37.mat``.

This dataset consists of various proxies sites over time, so we'll want to define metadata for the ``site`` and ``time`` dimensions. If we load the contents of the ``UK37.mat`` file::

.. code::
    :class: input

    contents = load('UK37.mat')

.. code::
    :class: output

    contents =

      struct with fields:

               ID: [89×1 string]
                Y: [0.4368 0.2450 0.6471 0.8455 0.5699 0.4688 0.8960 … ]
              lat: [89×1 double]
              lon: [89×1 double]
             time: [18.0010 21]
        timeUnits: 'ka'

we can see that the file includes metadata fields. These include an ID for each proxy site (ID), as well as the coordinates (lat and lon). The file also indicates that the dataset is time-averaged over the period from 18-21 ka.

We'll note that the proxy IDs, lats, and lons all pertain to the proxy sites, so we'll combine them as metadata for the ``site`` dimension. We'll use the "time" field directly as the time metadata::

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

Did you notice the warning message? This is because the ``time`` metadata has a single row. Remember that DASH requires metadata to have one row per element along a dimension, so our time metadata is representing a single time step. In this demo, we only have a single time step, so the time metadata is correct and we can ignore the warning.

Inspecting the metadata object:

.. code::
    :class: input

    disp(proxyMetadata)

.. code::
    :class: output

    gridMetadata with metadata:

      site: [89×3 string]
      time: [18.0010 21]

we can see that it includes metadata for the ``site`` and ``time`` dimensions.


*NTREND Demo: Climate Model Output*
-----------------------------------
Next, we'll create a metadata object for our climate model output. As a reminder, the climate model output is stored in the two NetCDF files ````b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.085001-184912.nc`` and ````b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.185001-200512.nc``. This output in each file is a global temperature field on a monthly time step. The first file holds output from 850-1849 CE, and the second holds output from 1850-2005 CE.

We can use Matlab's ``ncdisp`` command to display the contents of each file. For example::

    file1 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.185001-200512.nc';
    ncdisp(file1)

Doing so, we can see that each file contains metadata for ``lat``, ``lon``, and ``time``. We can use Matlab's ``ncread`` command to inspect these metadata values and decide if we want to use the NetCDF metadata as our metadata in DASH. Examining the ``lat`` and ``lon`` variables in the NetCDF file:

.. code::
    :class: input

    file = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.185001-200512.nc';
    lat = ncread(file, 'lat')

.. code::
    :class: output

    lat =

      -90.0000
      -88.1053
      -86.2105
           ...
       86.2105
       88.1053
       90.0000

.. code::
    :class: input

    ncread(file, 'lon')

.. code::
    :class: output

    lon =

             0
        2.5000
        5.0000
           ...
      352.5000
      355.0000
      357.5000

we can see that the NetCDF metadata holds latitude and longitude coordinates in decimal degrees. These metadata values are human-readable, so we'll go ahead and use them as our ``lat`` and ``lon`` metadata in DASH. Separately, we can use the ``ncdisp`` command to see that the time metadata in the NetCDF file is recorded in units of days since 0850-01-01::

.. code::
    :class: input

    ncdisp(file, 'time')

.. code::
    :class: output

    time
       Size:       12000x1
       Dimensions: time
       Datatype:   double
       Attributes:
                   long_name = 'time'
                   units     = 'days since 0850-01-01 00:00:00'
                   calendar  = 'noleap'
                   bounds    = 'time_bnds'

This metadata format is not particularly human readable, so we'll create our own metadata for the time dimension. Matlab's ``datetime`` format can be useful, because it allows users to sort data by specific years, months, and days, so we'll use a ``datetime`` format for our time metadata. The time metadata for the model output spans 850-2005 CE at monthly resolution, so we can create our time metadata using the following:

.. code::
    :class: input

    time = datetime(850,1,1) : calmonths(1) : datetime(2005,12,1);
    time = time'

.. code::
    :class: output

    time =

      13872×1 datetime array

       01-Jan-0850
       01-Feb-0850
       01-Mar-0850
       ...
       01-Oct-2005
       01-Nov-2005
       01-Dec-2005

Note that we converted the time metadata to a column vector in the second line of code. This is because ``gridMetadata`` requires metadata to have one *row* per element along a dimension. Putting it all together:

.. code::
    :class: input

    % Use NetCDF metadata for lat and lon
    file = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.185001-200512.nc';
    lat = ncread(file, 'lat');
    lon = ncread(file, 'lon');

    % Create time metadata
    time = datetime(850,1,1) : calmonths(1) : datetime(2005,12,1);
    time = time';

    % Create the metadata object
    modelMetadata = gridMetadata('lat', lat, 'lon', lon, 'time', time)

.. code::
    :class: output

    modelMetadata =

      gridMetadata with metadata:

         lon: [144×1 double]
         lat: [96×1 double]
        time: [13872×1 datetime]



Aside: Tripolar Spatial Fields
------------------------------
Not all climate models output spatial fields on a rectilinear spatial grid. This is particularly common for ocean models, which often record variables on a tripolar spatial grid. Tripolar output is often reported on a "latitude x longitude" array, but each element of the array represents a unique (latitude, longitude) coordinate. So even if the rows of the array are reported as "latitude", the latitude values will change with every row and column. Similarly, the longitude value will change at every row and column.

Ultimately, these tripolar arrays represent a collection of unique spatial sites, rather than a rectilinear latitude x longitude grid. As such, we'll typically use the ``site`` dimension to define spatial metadata for tripolar grids within DASH. To implement this, you'll usually want to reshape each of the ``latitude`` and ``longitude`` metadata arrays into a column vector. Then, concatenate the two vectors into a matrix with two columns. The two columns of the matrix record the unique (latitude, longitude) coordinate associated with each spatial site, and each row denotes a specific site.


*LGM Demo: Climate Model Output*
++++++++++++++++++++++++++++++++
Here, we'll create a metadata object for the climate model output. As a reminder, this output is stored in the file ``SST.mat``. Inspecting the contents of this file:

.. code::
    :class: input

    contents = load('SST.mat')

.. code::
    :class: output

    contents =

      struct with fields:

              SST: [320×384×12×16 double]
              lat: [320×384 double]
              lon: [320×384 double]
            month: [12×1 string]
              run: [16×1 double]
        time_span: "18-21 ka"

we can see that the saved SST output is on a tripolar spatial field. The file includes metadata for both the "lat" and "lon" dimensions, but the metadata for each "dimension" is a matrix with a unique value at each spatial point. We'll reshape this metadata to indicate that the spatial field consists of a collection of unique spatial sites::

    % Get the metadata matrices
    lat = contents.lat;
    lon = contents.lon;

    % Reshape into column vectors and append
    site = [lat(:), lon(:)];

To finish the metadata object for this dataset, we'll note that the tripolar SST output includes a climatology for each month of the year, and for 16 unique model runs. So the overall dataset is (site x time x run). The ``SST.mat`` file includes metadata for the month and run, and we'll use this metadata in DASH. Putting it all together:

.. code::
    :class: input

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

.. code::
    :class: output

    modelMetadata =

      gridMetadata with metadata:

        site: [122880×2 double]
        time: [12×1 string]
         run: [16×1 double]


Step 2: Return Metadata
-----------------------
You can return the metadata for a dimension using dot-indexing. For a given metadata object, follow the object by ``.<dimension name>``, where ``<dimension name>`` is one of the dimension in DASH. For example, ``.lat``, ``.lon``, ``.time``, etc.


*NTREND Demo*
-------------
To return the latitude metadata for the climate model output, we could do:

.. code::
    :class: input

    modelMetadata.lat

.. code::
    :class: output

    -90
    -88.105
    -86.211
    ...
    86.211
    88.105
     90

To return the metadata for the lon dimension, we can do:

.. code::
    :class: input

    modelMetadata.lon

.. code::
    :class: output

        0
      2.5
        5
      ...
    352.5
      355
    357.5

To return the metadata for the time dimension, we can do:

.. code::
    :class: input

    modelMetadata.time

.. code::
    :class: output

    01-Jan-0850
    01-Feb-0850
    01-Mar-0850
    ...
    01-Oct-2005
    01-Nov-2005
    01-Dec-2005



*LGM Demo*
----------
To return the site metadata for the climate model output, we can do:

.. code::
    :class: input

    modelMetadata.site

.. code::
    :class: output

    -79.221       320.56
    -79.221       321.69
    -79.221       322.81
        ...
     72.196       318.92
     72.189       319.35
     72.186       319.78

 To return the metadata for the time dimension (which organizes the 12 monthly climatologies), we can do:

.. code::
    :class: input

    modelMetadata.time

.. code::
    :class: output

    "Jan"
    "Feb"
    "March"
    "April"
    "May"
    "June"
    "July"
    "Aug"
    "Sep"
    "Oct"
    "Nov"
    "Dec"

To return the metadata for the 16 climate model runs, we can do:

.. code::
    :class: input

    modelMetadata.run

.. code::
    :class: output

    1
    2
    3
    4
    5
    6
    7
    8
    9
   10
   11
   12
   13
   14
   15
   16



Step 3: Create Metadata Attributes
----------------------------------
You can use the ``gridMetadata.addAttributes`` to add non-dimensional attributes to a ``gridMetadata`` object. The inputs to the command are a series of (Attribute Name, Attribute Value) pairs. The full syntax is::

    obj = obj.addAttributes(name1, value1, .., nameN, valueN)

Each attribute name must be a valid Matlab variable name - it must begin with a letter, and may only include letters, numbers, and underscores. The metadata values can be anything at all. They may have any size and any data type, and have no formatting requirements. Use whatever you find useful!


*NTREND Demo*
+++++++++++++
We'll start by adding some attributes to metadata object for the climate model output. We'll note that this output is from the CESM 1.0 climate model, and that the units of the raw data set are in Kelvin:

.. code::
    :class: input

    modelMetadata = modelMetadata.addAttributes("Model", "CESM 1.0", "raw_units", "Kelvin")

.. code::
    :class: output

    modelMetadata =

      gridMetadata with metadata:

               lon: [144×1 double]
               lat: [96×1 double]
              time: [13872×1 datetime]
        attributes: [1×1 struct]

      Show attributes

                Model: "CESM 1.0"
            raw_units: "Kelvin"


We'll also add some attributes to the metadata object for the proxy records. Here, we'll note that the columns of the site metadata correspond to each proxy site's ID, latitude, longitude, and optimal growing season:

.. code::
    :class: input

    name = 'site_metadata_columns';
    value = ["ID", "Latitude", "Longitude", "Season"];
    proxyMetadata = proxyMetadata.addAttributes(name, value)

.. code::
    :class: output

    proxyMetadata =

      gridMetadata with metadata:

              site: [54×4 string]
              time: [1262×1 double]
        attributes: [1×1 struct]

      Show attributes

            site_metadata_columns: ["ID"    "Latitude"    "Longitude"    "Season"]



*LGM Demo*
++++++++++
Here, we'll start by adding some attributes to the metadata object for the climate model output. We'll start by noting that the output is from the iCESM model, and is in units of Kelvin. We'll also note that the model was run with boundary conditions matching the interval from 18-21 ka. Finally, we'll indicate that the columns of the spatial metadata correspond to the latitude and longitude of each spatial site, respectively:

.. code::
    :class: input

    model = "iCESM";
    units = "Celsius";
    time = "18-21 ka";
    columns = ["Latitude", "Longitude"];
    modelMetadata = modelMetadata.addAttributes("Model", model "Units", units, ...
                         "time_span", time, "site_metadata_columns", columns);

.. code::
    :class: output

      gridMetadata with metadata:

              site: [122880×2 double]
              time: [12×1 string]
               run: [16×1 double]
        attributes: [1×1 struct]

      Show attributes

                        time_span: "18-21 ka"
                            Units: "Celsius"
                            Model: "iCESM"
            site_metadata_columns: ["Latitude"    "Longitude"]

We'll also add some attributes to the metadata object for the proxy records. Here, we'll note that the time metadata has units of ka, and that the proxy records are all UK'37 values. We'll also indicate that the columns of the site metadata record each proxy site's ID, latitude, and longitude:

.. code::
    :class: input

    proxyMetadata = proxyMetadata.addAttributes("time_units", "ka", "type", "UK'37", ...
                             'site_metadata_columns', ["ID","Latitude","Longitude"])

.. code::
    :class: output

    proxyMetadata =

      gridMetadata with metadata:

              site: [89×3 string]
              time: [18.001 21]
        attributes: [1×1 struct]

      Show attributes

                       time_units: "ka"
                             type: "UK'37"
            site_metadata_columns: ["ID"    "Latitude"    "Longitude"]




Additional Commands
-------------------
These are the key commands for the ``gridMetadata`` class, but there are a number of other commands not discussed in this tutorial. For example, the class includes commands to edit and remove metadata values and metadata attributes. You can read about the other commands in this class on the :doc:`gridMetadata reference page <../../gridMetadata>_:

    dash.doc('gridMetadata')



Full Demos
----------
This section recaps all the essential code from the demos.

*NTREND Demo*
+++++++++++++

::

    %% Proxy Records

    % Load metadata fields from the proxy records file
    contents = load('ntrend.mat');
    IDs = contents.IDs;
    lats = contents.latitudes;
    lons = contents.longitudes;
    years = contents.years;

    % Combine IDs, lats, and lons into "site" metadata
    site = [IDs, lats, lons];

    % Create the metadata object
    proxyMetadata = gridMetadata('site', site, 'time', years);

    % Add metadata attributes
    name = 'site_metadata_columns';
    columns = ["ID", "Latitude", "Longitude", "Season"];
    proxyMetadata = proxyMetadata.addAttributes(name, columns);

    % Add attributes
    name = 'site_metadata_columns';
    value = ["ID", "Latitude", "Longitude", "Season"];
    proxyMetadata = proxyMetadata.addAttributes(name, value)


    %% Climate Model Output

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
    modelMetadata = modelMetadata.addAttributes("Model", "CESM 1.0", "Units", "Kelvin")




*LGM Demo*
++++++++++

::

    %% Proxy records

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

    % Add attributes
    proxyMetaadata = proxyMetadata.addAttributes("time_units", "ka", "type", "UK'37", ...
                             'site_metadata_columns', ["ID","Latitude","Longitude"]);


    %% Climate model output

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
