dash.dataSource
===============
Classes that read data from different types of sources files

The Interface class implements an interface for loading data from source files. Subclasses actually implement the steps needed to extract data from different types of files.

These classes are used by gridfile objects to load data from different files within a common framework.


.. toctree::
    :hidden:

    Interface <dataSource/Interface>
    hdf <dataSource/hdf>
    mat <dataSource/mat>
    nc <dataSource/nc>
    text <dataSource/text>
    tests <dataSource/tests>
.. raw:: html

    <h3>Abstract Superclasses</h3>

.. rst-class:: package-links

| :doc:`Interface <dataSource/Interface>` - Interface for objects that read data from a source file
| :doc:`hdf <dataSource/hdf>` - Superclass for objects that read data from HDF5 files



.. raw:: html

    <h3>Concrete Subclasses</h3>

.. rst-class:: package-links

| :doc:`mat <dataSource/mat>` - Objects that read data from MAT-files
| :doc:`nc <dataSource/nc>` - Objects that read data from NetCDF files
| :doc:`text <dataSource/text>` - Objects that read data from delimited text files



.. raw:: html

    <h3>Tests</h3>

.. rst-class:: package-links

| :doc:`tests <dataSource/tests>` - Unit tests for classes in the package

