Open Coding 2
=============

Goal
----
Explore the demo datasets using ``gridfile`` commands.


Step 1: Inspect data catalogues
-------------------------------
Before continuing, take a few minutes to explore your chosen demo dataset. As mentioned, each dataset contains several files with a ``.grid`` extension. These are data catalogues built using DASH's ``gridfile`` utility, and these catalogues will help facilitate the assimilations. You can inspect the data catalogues using the ``gridfile`` command with the name of a ``.grid`` file as input::

    gridfile(filename)

where **filename** is a string that lists the name of a ``.grid`` file. Try it out!



..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-1"><label for="ntrend-1"><strong>NTREND Demo</strong></label><div class="content">


We'll use the ``gridfile`` command to examine the ``ntrend.grid`` dataset.

.. code::
    :class: input

    gridfile('ntrend')

.. code::
    :class: output

    gridfile with properties:

            File: some/path/to/Hackathon/demo/ntrend.grid
      Dimensions: site, time

      Dimension Sizes and Metadata:
          site:   54
          time: 1262    (750 to 2011)

      Attributes:
          site_metadata_columns: ["ID"    "Latitude"    "Longitude"    "Season"]

      Fill Value: -999.000000

      Data Sources: 1

    Show data sources

          1. some/path/to/Hackathon/demo/ntrend.mat   Show details

From the output, we can see that this catalogue manages data from 54 proxy sites over the period 750-2011 CE. The catalogue includes metadata for each site, and this metadata includes each site's ID, latitude, longitude, and optimal growing season. The data in the catalogue is sourced from the ``ntrend.mat`` file that was downloaded with the demo.

.. raw:: html

    </div></section>





..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-1"><label for="lgm-1"><strong>LGM Demo</strong></label><div class="content">


We'll use the ``gridfile`` command to examine the ``UK37.grid`` dataset.

.. code::
    :class: input

    gridfile('UK37')

.. code::
    :class: output

    gridfile with properties:

            File: some/path/to/Hackathon/demos/LGM/UK37.grid
      Dimensions: site, time

      Dimension Sizes and Metadata:
          site: 89
          time:  1

      Attributes:
                     time_units: "ka"
                     proxy_type: "UK'37"
          site_metadata_columns: ["ID"    "Latitude"    "Longitude"]

      Data Sources: 1

    Show data sources

          1. some/path/to/Hackathon/demos/LGM/UK37.mat   Show details

From the output, we can see that this catalogue manages data from 89 UK'37 sites. The catalogue includes metadata for each site, and this metadata includes each site's ID, latitude, and longitude. The data in the catalogue is sourced from the ``UK37.mat`` file that was downloaded with the demo.

.. raw:: html

    </div></section>




Step 2: Examine metadata
------------------------
Each gridfile catalogue includes metadata for each dimension of the dataset. This dimensional metadata will be helpful later in the workshop, so let's examine it now. You can return the metadata for a gridfile catalogue using the ``gridfile.metadata`` command. Here the syntax is::

    metadata = obj.metadata

where **obj** is a gridfile object output by the ``gridfile`` command. Alternatively, you can combine the two commands using dot-indexing, via::

    metadata = gridfile(filename).metadata

In either case, the output is a metadata object that describes the dataset. You can use the metadata object like a matlab ``struct``. To get the metadata for a particular dimension, use ``metadata.<dimension name>``. See the demos below for examples.


..
    *NTREND Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="ntrend-2"><label for="ntrend-2"><strong>NTREND Demo</strong></label><div class="content">

We'll first use the ``metadata`` command to obtain the metadata for the ``ntrend.grid`` catalogue:

.. code::
    :class: input

    metadata = gridfile('ntrend').metadata

.. code::
    :class: output

    metadata =

      gridMetadata with metadata:

              site: [54×4 string]
              time: [1262×1 double]
        attributes: [1×1 struct]

From the output, we can see that the catalogue includes metadata for the ``site`` and ``time`` dimensions, as well as some non-dimensional attributes. We can inspect the metadata for the ``site`` dimension:

.. code::
    :class: input

    metadata.site

.. code::
    :class: output

    54×4 string array

      "NTR"       "65.2833"    "-161.65"      "7,8"
      "GOA"       "59.9167"    "-139.25"      "1,2,3,4,5,6,7,8,9"
      "WRAx"      "62.5"       "-141.5"       "6,7,8"
      ...
      "Grid18"    "51.25"      "144.25"       "6,7"
      "NJAP"      "43.3667"    "142.85"       "6,7"
      "YAK"       "69"         "146"          "6"

and see the ID, latitude, longitude, and growing season for each site. Similarly, we can inspect the metadata for the ``time`` dimension:

.. code::
    :class: input

    metadata.time

.. code::
    :class: output

     750
     751
     752
     ...
    2009
    2010
    2011

and see that the proxy data ranges from 750 CE to 2011 CE.

Now that you've examined the proxy data catalogue, try using these commands to investigate the climate model output.


.. raw:: html

    </div></section>




..
    *LGM Demo*
    +++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="lgm-2"><label for="lgm-2"><strong>LGM Demo</strong></label><div class="content">

We'll first use the ``metadata`` command to obtain the metadata for the ``uk37.grid`` catalogue:

.. code::
    :class: input

    metadata = gridfile('uk37').metadata

.. code::
    :class: output

    metadata =

      gridMetadata with metadata:

              site: [89×3 string]
              time: [18.0010 21]
        attributes: [1×1 struct]

From the output, we can see that the catalogue includes metadata for the ``site`` and ``time`` dimensions, as well as some non-dimensional attributes. We can inspect the metadata for the ``site`` dimension:

.. code::
    :class: input

    metadata.site

.. code::
    :class: output

    146×3 string array

      "bs79-33"          "38.2617"     "14.03"
      "ch07-98_ggc19"    "36.8667"     "-74.56667"
      "churruca"         "-53.0548"    "-73.92933"
      ...
      "vm19-30"           "-3.383"      "-83.52"
      "w8709a-8pc"        "42.242"      "-127.678"
      "w8709a-8tc"        "42.242"      "-127.678"

and see the ID, latitude, and longitude for each site. Similarly, we can inspect the metadata for the ``time`` dimension:

.. code::
    :class: input

    metadata.time

.. code::
    :class: output

    18.0010   21.0000

and see that the proxy data is averaged over the interval from 18-21 ka.

Now that you've examined the proxy data catalogue, try using these commands to investigate the climate model output.

.. raw:: html

    </div></section>
