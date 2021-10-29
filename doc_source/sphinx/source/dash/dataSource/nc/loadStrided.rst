dash.dataSource.nc.loadStrided
==============================
Load data from a NetCDF file at strided indices

----

Syntax
------

.. rst-class:: syntax

| :ref:`X = obj.loadStrided(stridedIndices) <dash.dataSource.nc.loadStrided.syntax1>`

----

Description
-----------

.. _dash.dataSource.nc.loadStrided.syntax1:

.. rst-class:: syntax

:ref:`X <dash.dataSource.nc.loadStrided.output.X>` = obj.loadStrided(:ref:`stridedIndices <dash.dataSource.nc.loadStrided.input.stridedIndices>`)

Load data from the variable in the NetCDF file at the specified strided indices


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.dataSource.nc.loadStrided.input.stridedIndices:

stridedIndices
++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>stridedIndices</strong></label><div class="content">

| *cell* *vector* [*nDims*] {*vector*, *strided* *linear* *indices*}
| The indices of data elements along each dimension to load from the NetCDF file. Should have one element per dimension of the variable. Each element holds a vector of strided linear indices.

.. raw:: html

    </div></section>


----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.dataSource.nc.loadStrided.output.X:

X
+

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>X</strong></label><div class="content">

| *array*
| The loaded data

.. raw:: html

    </div></section>


