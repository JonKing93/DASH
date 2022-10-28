gridMetadata
============

We'll begin our tour of the DASH toolbox with the gridMetadata class. This class assigns human-readable metadata to climate datasets, which allows users to manipulate data using human-readable values. The class operates by enabling users to build metadata objects that describe the information in a given dataset. These metadata objects are used as input to later DASH commands to catalogue and manipulate saved datasets.


N-dimensional datasets
----------------------

A gridMetadata object holds metadata values along each dimension of an N-dimensional gridded dataset. By default, the DASH toolbox includes support for up to 7 dataset dimensions:

1. ``lat``: Latitude / X coordinate
2. ``lon``: Longitude / Y coordinate
3. ``lev``: Level / Height / Z coordinate
4. ``site``: Non-rectilinear spatial coordinate
5. ``time``: Time
6. ``run``: Model run / Ensemble member
7. ``var``: Climate variable

although users can modify the toolbox to support additional dimensions (see :ref:`the next coding session <edit-dimensions>`). Note that metadata objects **do not** need to define metadata for all 7 dimensions (in fact, this is almost never necessary). Instead, users should pick and choose the dimensions appropriate for their datasets.

To create a metadata object, use the ``gridMetadata`` command. The inputs to this command are a series of (Dimension-Name, Metadata-Values) pairs. For example, to create metadata for a dataset over 3 spatial dimensions, you could do::

    metadataObject = gridMetadata("lat", latMetadata, "lon", lonMetadata, "lev", levMetadata)

Similarly, to create metadata for a series of randomly-distributed proxy sites over time, you could do::

    metadataObject = gridMetadata("site", siteMetadata, "time", timeMetadata)

In the next section, we will see how to design the metadata values for a given dataset dimension.


Dimensional metadata
--------------------

The metadata for each dimension should be a matrix, and the number of rows should match the length of the dimension. The matrix may have any number of columns. The ``gridMetadata`` class aims to provide flexibility when defining dimensional metadata. Metadata values may be numeric, char, string, cellstring, or datetime data types, and there is no required format for the metadata along any dimension. Use whatever you find useful!

Also note that the metadata matrices for different dimensions may have different data types and different numbers of columns. For example, say you have a dataset with both ``site`` and ``time`` dimensions. It is perfectly acceptable for the ``site`` metadata to be a string datatype with 4 columns, and the ``time`` metadata to be a numeric datatype with 1 column.

You can return a metadata object's dimensional metadata using dot-indexing with the dimension's name. For example, if you create a metadata object with ``lat`` metadata:

.. code::
    :class: input

    latMetadata = (-90:90)';
    myObject = gridMetadata('lat', latMetadata)

.. code::
    :class: output

    myObject =

      gridMetadata with metadata:

        lat: [181x1 double]

Then you can return the ``lat`` metadata using:

.. code::
    :class: input

    myObject.lat

.. code::
    :class: output

    ans =

        -90
        -89
        -88
        ...
         88
         89
         90


Non-dimensional metadata attributes
-----------------------------------

It's often useful to associate some non-dimensional metadata with a dataset. For example, the name of the model associated with some climate model output, or the units of the dataset. The ``gridMetadata`` class supports such non-dimensional metadata, which are referred to as **"attributes"**. To include attributes in a metadata object, include a (``"attributes"``, Metadata-Attributes) pair in the inputs to the ``gridMetadata`` command. The Metadata-Attributes input should be a scalar ``struct`` with some fields. Each field is interpreted as the name of a metadata attributes. You may use any field names you find useful - there are no required names for metadata attributes. The content of each field is the metadata associated with the attribute. There are no formatting requirements for metadata attributes; they may be any data type, and may have any size.

The metadata attributes should be included in the ``gridMetadata`` command. So for example:

.. code::
    :class: input

    myAttributes = struct("Model", "My Model Name", "Units", "Kelvin", "Some_array", rand(4,5,6))
    meta = gridMetadata("lat", latMetadata, "lon", lonMetadata, "attributes", myAttributes)

.. code::
    :class: output

    meta =

      gridMetadata with metadata:

               lon: [360×1 double]
               lat: [181×1 double]
        attributes: [1×1 struct]

      Show attributes

                 Model: "My Model Name"
                 Units: "Kelvin"
            Some_array: [4×5×6 double]


Alternatively, you can use the ``addAttributes`` command to add attributes to an existing metadata object. The inputs to this command are a series of (Attribute-Name, Attribute-Value) pairs. The output is the updated metadata object. For example, if you have a metadata object with no attributes:

.. code::
    :class: input

    meta = gridMetadata("lat", latMetadata, "lon", lonMetadata)

.. code::
    :class: output

    meta =

      gridMetadata with metadata:

        lon: [360×1 double]
        lat: [181×1 double]

Then you could add attributes using:

.. code::
    :class: input

    meta = meta.addAttributes("Model", "My Model Name", "Units", "Kelvin", "Some_array", rand(4,5,6))

.. code::
    :class: output

    meta =

      gridMetadata with metadata:

               lon: [360×1 double]
               lat: [181×1 double]
        attributes: [1×1 struct]

      Show attributes

                 Model: "My Model Name"
                 Units: "Kelvin"
            Some_array: [4×5×6 double]

Note that the attribute names must all be valid Matlab variable names when using the ``addAttributes`` command.


*Returning Attributes*
++++++++++++++++++++++

You can return a metadata object's attributes using dot-indexing with ``.attributes``. Continuing the previous example:

.. code::
    :class: input

    meta.attributes

.. code::
    :class: output

    ans =

      struct with fields:

             Model: "My Model Name"
             Units: "Kelvin"
        Some_array: [4×5×6 double]


You can return a specific attribute by using a second layer of dot-indexing with the name of the attribute. For example:

.. code::
    :class: input

    meta.attributes.Model

.. code::
    :class: output

    ans =

        "My Model Name"

.. tip::

    The help page for ``gridMetadata`` reports additional commands that can be used to manipulate metadata attributes. Access the help page by entering ``dash.doc("gridMetadata")`` in the console.
