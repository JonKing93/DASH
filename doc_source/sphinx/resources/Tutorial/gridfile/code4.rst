Open Coding 4
=============

Goal
----
In this session, we'll use ``gridfile`` to create a data catalogue for climate model output.


Step 1: Create ``.grid`` file
-----------------------------
We'll use the ``gridfile.new`` command again to create a new catalogue for our climate model dataset. As a reminder, the syntax is::

    grid = gridfile.new(filename, metadata)

Climate model output often spans multiple data files, so be sure that the **metadata** input defines the scope of the entire dataset.

.. note::
    DASH supports the ``var`` dimensions for different climate variables, so you can group multiple climate variables in the same catalogue. However, sometimes it's easier to create separate catalogues for different variables - particularly when applying unit conversions or other data adjustments.

    Ultimately, there's no "correct" way. Use whichever style works best for you.


*Demo*
++++++
As a reminder, we have demo climate model output for surface temperatures. The output is arranged on a global latitude-longitude grid over time. Time proceeds from 850 CE to 2005 CE at monthly resolution. The output is split over two NetCDF files with the first 1000 years of output in the first file, and the remaining years in the second file. We `previously showed <code2.html#demo-2>`_ how to build a ``gridMetadata`` object for this dataset::

    % Get the output files
    outputFile1 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.085001-184912.nc';
    outputFile2 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.185001-200512.nc';

    % Define metadata that spans the climate model output dataset
    lat = ncread(outputFile1, 'lat');
    lon = ncread(outputFile1, 'lon');
    time = datetime(850,1,15):calmonths(1):datetime(2005,12,15);

    % Create a metadata object
    metadata = gridMetadata("lat", lat, "lon", lon, "time", time');
    metadata = metadata.addAttributes("Units", "Kelvin", "Model", "CESM 1.0");

Now we'll use the metadata object to define the scope of a catalogue for the climate model output. Here, we'll name the new catalogue ``temperature-cesm.grid``::

    % Use the metadata to initialize a new gridfile catalogue
    file = "temperature-cesm.grid";
    grid = gridfile.new(file, metadata);

Inspecting the new gridfile:

.. code::
    :class: input

    disp(grid)

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

        Data Sources: 0

we can see that it manages the data catalogue for our model output.



Step 2: Add data sources
------------------------
We'll again use the ``gridfile.add`` command to add data source files to the catalogue. We'll need to call the command once for each data file. As a reminder, the syntaxes are::

    % NetCDF and MAT-files
    obj.add(type, filename, variable, dimensions, metadata)

    % Delimited text files
    obj.add("text", filename, dimensions, metadata, .., options, ..)

Remember that the metadata object for each data file should only have metadata values for the data subset in the file. Also recall that the metadata should include values for each dimension in the ``.grid`` catalogue. The ``gridMetadata.index`` command can be useful for extracting metadata subsets from the gridfile's metadata.

.. important::
    If your dataset uses tripolar coordinates or another non-rectilinear coordinate system, please see the next section. If not, feel free to skip to the next demo.


*Merged dimensions / Tripolar coordinates*
++++++++++++++++++++++++++++++++++++++++++
The ``gridfile`` class requires each element along a data dimension to have unique, fixed metadata. However, some climate model coordinate systems don't fall neatly into this paradigm, and so an additional step may be required to add model output to a ``.grid`` catalogue.

This often occurs for variables on tripolar spatial grids. Tripolar output is often organized as a 2D (longitude x latitude) spatial grid, but spatial metadata is not fixed at a given point along either data dimension. For example, the latitude coordinate at (latitude_j, longitude_k) is typically not the same as at (latitude_j, longitude_k+1). Essentially, these spatial grids describe values at a set of unique (latitude, longitude) points, rather than values on a rectilinear (latitude x longitude) grid.

To facilitate the use of such grids, ``gridfile`` allows users to merge multiple data file dimensions into a single, vectorized dimension within a ``.grid`` catalogue. For example, consider our tripolar (latitude x longitude) spatial grid. As noted, this spatial grid represents a collection of unique (latitude, longitude) points, and this matches the description of the ``site`` dimension, rather than distinct ``lat`` and ``lon`` dimensions. As such, we should merge the latitude and longitude dimensions of the data file into a single ``site`` dimension for the ``.grid`` catalogue.

As a reminder, the syntax for adding a data source file is::

    obj.add(type, filename, variable, dimensions, metadata)

To merge data file dimensions, you should use a repeated dimension name in the **dimensions** input. The **dimensions** input should still have one element per data file dimension, but the elements for merged dimensions should list the same dimension name.

Example
~~~~~~~

.. note::
    You can find the files for this example in the ``tripolar-example`` folder of the demo download.

In this example , we have climate model output of sea-surface temperatures (SSTs) over time. The SSTs are provided on a tripolar spatial grid. The dataset progresses from 1200-1299 CE at monthly resolution. The dataset is saved in the NetCDF file ``b.e11.BLMTRC5CN.f19_g16.002.pop.h.SST.120001-129912.nc`` within the ``SST`` variable.

By examining the SST variable::

    file = "b.e11.BLMTRC5CN.f19_g16.002.pop.h.SST.120001-129912.nc";
    variable = "SST";
    ncdisp(file, variable)

we can see that the dataset has a size of (320 x 384 x 1 x 1200), which corresponds to a Longitude (nlon) x Latitude (nlat) x Depth (z_t) x Time array. However, if we load and examine metadata for the ``lat`` dimension, we can see that the spatial metadata is a matrix:

.. code::
    :class: input

    lat = ncread(file, 'TLAT');
    size(lat)

.. code::
    :class: output

    ans =

       320   384

and values are not fixed along the latitude dimension:

.. code::
    :class: input

    % Changing longitude index, Fixed latitude index
    latA = lat(83, 359)
    latB = lat(84, 359)

.. code::
    :class: output

    latA =
              73.1

    latB =
              73.3

so the spatial grid represents a collection of unique points, rather than a rectilinear grid. Thus, we should merge the longitude and latitude dimensions of the data file into a single ``site`` dimension for the ``.grid`` catalogue. We'll start by using the latitude and longitude metadata to define metadata for a ``.grid`` file with a ``site`` dimension::

    % Get the spatial metadata
    lat = ncread(file, 'TLAT');
    lon = ncread(file, 'TLONG');

    % Reshape metadata as a collection of unique points
    site = [lat(:), lon(:)];

    % Build metadata object
    lev = "Surface";
    time = ncread(file, 'time');
    metadata = gridMetadata('site', site, 'lev', lev, 'time', time);

    % Create gridfile
    grid = gridfile.new('sst.grid', metadata);



Next, we'll merge the latitude and longitude dimensions when we add data source files::

    % Whereas we might initially write
    % dimensions = ["lon", "lat", "lev", "time"];

    % We'll change this to
    dimensions = ["site", "site", "lev", "time"];

    % Then add the data source file to the catalogue
    metadata = grid.metadata;
    grid.add("netcdf", file, variable, dimensions, metadata);


*Demo*
++++++
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

            File: path/to/Hackathon/demo/temperature-cesm.grid
      Dimensions: lon, lat, time

      Dimension Sizes and Metadata:
           lon:   144    (          0 to 357.5      )
           lat:    96    (        -90 to 90         )
          time: 13872    (15-Jan-0850 to 15-Dec-2005)

      Attributes:
          Units: "Kelvin"
          Model: "CESM 1.0"

      Data Sources: 2

    Show data sources

          1. path/to/Hackathon/demo/b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.085001-184912.nc   Show details
          2. path/to/Hackathon/demo/b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.185001-200512.nc   Show details

we can see it now includes the two NetCDF files as data sources.


Step 3: Data Adjustments
------------------------
Once again, we'll apply any data adjustments to our dataset. As a reminder, the syntaxes for data adjustments are::

    obj.fillValue(value)

    obj.validRange(range)

    obj.transform(type, parameters)


*Demo*
++++++
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


Full Demo
---------------
This section recaps all the essential code from the demos. You can use it as a quick reference::

    % Get the output files
    outputFile1 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.085001-184912.nc';
    outputFile2 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.185001-200512.nc';

    % Define metadata that spans the climate model output dataset
    lat = ncread(outputFile1, 'lat');
    lon = ncread(outputFile1, 'lon');
    time = datetime(850,1,15):calmonths(1):datetime(2005,12,15);

    % Create a metadata object
    metadata = gridMetadata("lat", lat, "lon", lon, "time", time');
    metadata = metadata.addAttributes("Units", "Kelvin", "Model", "CESM 1.0");

    % Use the metadata to initialize a new gridfile catalogue
    file = "temperature-cesm.grid";
    gridfile.new(file, metadata);

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
