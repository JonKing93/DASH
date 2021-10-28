dash.dataSource.hdf.load
========================
Load data from a HDF5 source

----

Syntax
------

.. rst-class:: syntax

| :ref:`X = obj.load(indices) <dash.dataSource.hdf.load.syntax1>`

----

Description
-----------

.. _dash.dataSource.hdf.load.syntax1:

.. rst-class:: syntax

:ref:`X <dash.dataSource.hdf.load.output.X>` = obj.load(:ref:`indices <dash.dataSource.hdf.load.input.indices>`)

Loads data from a HDF source at the requested linear indices. Acquires data along strided intervals but only returns requested indices.


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.dataSource.hdf.load.input.indices:

indices
+++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>indices</strong></label><div class="content">

| *cell* *vector* [*nDims*] {*vector*, *linear* *indices*}
| The indices of data elements along each dimension to load from the HDF5 file. Should have one element per dimension of the variable. Each element holds a vector of linear indices.

.. raw:: html

    </div></section>


----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.dataSource.hdf.load.output.X:

X
+

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>X</strong></label><div class="content">

| *array*
| The loaded data

.. raw:: html

    </div></section>


