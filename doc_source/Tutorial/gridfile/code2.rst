Open Coding 2
=============

In this session, we will practice using the ``gridMetadata`` class to create metadata objects for climate datasets. Steps 1 and 2 provide some practice problems for using ``gridMetadata``, and solutions are provided at the bottom of the page. If you already feel confident using the class, feel free to skip directly to step 3 and create metadata objects for your own datasets.


Goals
-----
By the end of the session, participants should be able to create metadata objects for their own datasets.



Step 1: Practice Creating Metadata
----------------------------------
Use the ``gridMetadata`` command to create metadata for the following datasets. Solutions are provided at the bottom of the page.


*Practice A*
++++++++++++
The dataset has 3 dimensions: latitude, longitude, and time. Latitude extends from the equator to the North pole in steps of 1 degree. Longitude metadata proceeds from 0 to 355 in steps of 5 degrees. The dataset extends over the Common Era from 1-2000 CE with an annual time step.

*Practice B*
++++++++++++
Same as practice A, but with a monthly time step.

*Practice C*
++++++++++++
The dataset consists of measurements from a series of proxy sites over time. The spatial coordinates and altitude of each proxy site are given below. The proxy dataset extends from the Last Glacial Maximum (at 24 ka) to present (0 ka) in steps of 3 kyr.

::

    coordinates = [1 2
                   3 4
                   5 6]
    altitude = [100; 200; 300]

*Practice D*
++++++++++++
Same as practice C, but the metadata should also include each proxy site's ID.

::

    siteID = ["13AB1"; "14CD2"; "8Xa"]

.. hint::

    You can use Matlab's ``string`` command to convert numeric matrices to string matrices



Step 2: Practice Metadata Attributes
------------------------------------
Add attributes to a metadata object. Do this by either including attributes in the ``gridMetadata`` command, or by using the ``addAttributes`` command to add attributes to an exisiting metadata object.

*Practice E*
++++++++++++
For the dataset from practice problem A, indicate that the units of the dataset are in Kelvin. Also include the following cell area weights as a metadata attribute::

    weights = repmat(cosd(0:90), 72, 1)



Step 3: Create Metadata for Real Datasets
-----------------------------------------
Create a gridMetadata object for at least one dataset you brought to the workshop. Create some dimensional metadata that you find useful - this could be metadata read from a NetCDF or MAT file, or some other values that you prefer. Use the ``gridMetadata`` command to create the metadata object. Optionally include some attributes to better document the dataset.

.. _edit-dimensions:

.. note::
    You can also edit the dimensions supported by the ``DASH`` toolbox by modifying the ``gridMetadata`` class (although this probably won't be necessary for the workshop). To modify the class, enter::

        edit gridMetadata

    in the console. Locate the line that states::

        properties (SetAccess = private)

    (near line 70), and follow the instructions below the line.


.. _demo-ntrend-metadata:

*Demo 1*
++++++++
In the demo dataset, the proxy dataset consists of 54 proxy records that span most of the Common Era at annual resolution. We'll start by defining metadata for this dataset. The MAT-file ``ntrend.mat`` holds metadata values for the proxy sites and for the covered time steps. We'll use this metadata to build a ``gridMetadata`` object::

    % Load metadata for the proxy dataset
    proxyFile = "ntrend.mat";
    info = load(proxyFile, 'IDs', 'latitudes', 'longitudes', 'seasons', 'years');

    % Build a gridMetadata object
    site = [info.IDs, info.latitudes, info.longitudes, info.seasons];
    time = info.years;
    metadata = gridMetadata('site', site, 'time', time);

Examining the new metadata object:

.. code::
    :class: input

    disp(metadata)


.. code::
    :class: output

    metadata =

      gridMetadata with metadata:

        site: [54×4 string]
        time: [1262×1 double]

we can see that the metadata object defines metadata for 54 proxy sites over 1262 time steps.


*Demo 2*
++++++++
The demo also includes climate model output for surface temperatures. This output is arranged on a global latitude-longitude grid over time. Time proceeds from 850 CE to 2005 CE at monthly resolution. The output is split over two NetCDF files with the first 1000 years of output in the first file, and the remaining years in the second file.

We'll use the latitude and longitude metadata from the NetCDF files, but we'll create custom metadata for the time dimension using Matlab's ``datetime`` format. We'll use this metadata to create a ``gridMetadata`` object::

    % Get the output files
    outputFile1 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.085001-184912.nc';
    outputFile2 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.185001-200512.nc';

    % Use the latitude/longitude metadata stored in the NetCDF files...
    lat = ncread(outputFile1, 'lat');
    lon = ncread(outputFile1, 'lon');

    % ... but use a custom metadata format for time
    % (These are monthly "datetime" values from January 850 to December 2005)
    time = datetime(850,1,15) : calmonths(1) : datetime(2005,12,15);

    % Create the metadata object and include some attributes
    metadata = gridMetadata("lat", lat, "lon", lon, "time", time');
    metadata = metadata.addAttributes("Units", "Kelvin", "Model", "CESM 1.0");

We can examine the metadata object in the console to ensure it matches our expectations:

.. code::
    :class: input

    disp(metadata)

.. code::
    :class: output

    metadata =

      gridMetadata with metadata:

               lon: [144×1 double]
               lat: [96×1 double]
              time: [13872×1 datetime]
        attributes: [1×1 struct]

      Show attributes

            Units: "Kelvin"
            Model: "CESM 1.0"





Step 4: Optional Reading
------------------------
If you finish early, check out the ``gridMetadata`` documentation page to see additional commands and options. For example, the ``edit`` command can be used to alter the metadata for a dimension. Separately, the ``index`` command can be used to return metadata at specific elements along a dimension. To open the documentation page, enter::

    dash.doc('gridMetadata')

in the console.



Solutions
---------

*Practice A*
++++++++++++

::

    lat = 0:90;
    lon = 0:5:355;
    time = 1:2000;
    meta = gridMetadata("lat", lat', "lon", lon', "time", time')

.. caution::

    Remember that ``gridMetadata`` interprets each **row** as a unique metadata value. Be sure that ``lat``, ``lon``, and ``time``, are provided as column vectors.


*Practice B*
++++++++++++

There are a number of ways to create monthly time metadata. Potential options include using decimal years::

    time = linspace(1, 2000, 2000*12)

or a date vector::

    years = repmat(1:2000, 12, 1);
    months = repmat((1:12)', 2000, 1);
    time = [years(:), months];

However, we recommend using Matlab's ``datetime`` format, which allow you to sort values by years, months, and days. (this functionality can be useful later when building state vector ensembles)::

    time = datetime(1,1,1) : calmonths(1) : datetime(2000,12,1)
    meta = gridMetadata("lat", lat', "lon", lon', "time", time')


*Practice C*
++++++++++++

::

    site = [coordinates, altitude];
    time = 24:-3:0;
    meta = gridMetadata("site", siteMetadata, "time", time')


*Practice D*
++++++++++++

::

    % Convert numeric metadata to string
    coordinates = string(coordinates);
    altitude = string(altitude);

    % Build the metadata object
    site = [coordinates, altitude, siteID];
    time = 24:-3:0;
    meta = gridMetadata("site", site, "time", time)


*Practice E*
++++++++++++

Using ``gridMetadata``::

    attributes = struct('Units', 'Kelvin', 'areaWeights', weights);
    meta = gridMetadata("lat", lat', "lon", lon', "time", time', "attributes", attributes)

Or using ``addAttributes``::

    meta = gridMetadata("lat", lat', "lon", lon', "time", time');
    meta = meta.addAttributes("Units", "Kelvin", "areaWeights", weights)
