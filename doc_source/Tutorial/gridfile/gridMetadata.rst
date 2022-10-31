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

Note that metadata objects **do not** need to define metadata for all 7 dimensions (in fact, this is almost never necessary). Instead, users should pick and choose the dimensions appropriate for their datasets.

.. note::

    You can modify ``gridMetadata`` to support additional dimensions, or to rename existing dimensions. To do so, enter ``edit gridMetadata`` in the Matlab console, and scroll down to the line ``properties (SetAccess = private)`` (around line 70). Follow the instructions in the comments below this line to edit the dimensions.




Dimensional metadata
--------------------

The metadata for each dimension should be a matrix, and the number of rows should match the length of the dimension. The matrix may have any number of columns. The ``gridMetadata`` class aims to provide flexibility when defining dimensional metadata. Metadata values may be numeric, char, string, cellstring, or datetime data types, and there is no required format for the metadata along any dimension. Use whatever you find useful!

Also note that the metadata matrices for different dimensions may have different data types and different numbers of columns. For example, say you have a dataset with both ``site`` and ``time`` dimensions. It is perfectly acceptable for the ``site`` metadata to be a string datatype with 4 columns, and the ``time`` metadata to be a numeric datatype with 1 column.




Non-dimensional metadata attributes
-----------------------------------

It's often useful to associate some non-dimensional metadata with a dataset. For example, the name of the model associated with some climate model output, or the units of the dataset. The ``gridMetadata`` class supports such non-dimensional metadata, which are referred to as **"attributes"**.

Within DASH, you can use anything as a metadata attribute. Attributes may be strings, arrays, class objects, etc., and there are no formatting requirements.
