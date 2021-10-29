dash.indices.keep
=================
Identify requested indices in superset of loaded indices

----

Syntax
------

.. rst-class:: syntax

| :ref:`keep = dash.indices.keep(requested, loaded) <dash.indices.keep.syntax1>`

----

Description
-----------

.. _dash.indices.keep.syntax1:

.. rst-class:: syntax

:ref:`keep <dash.indices.keep.output.keep>` = dash.indices.keep(:ref:`requested <dash.indices.keep.input.requested>`, :ref:`loaded <dash.indices.keep.input.loaded>`)

Takes the linear indices of requested data elements and compares them to the linear indices of loaded data elements. Returns the linear indices of the requested data elements within the loaded set of data.


----

Examples
--------

.. rst-class:: collapse-examples

Find requested data indices in a superset of loaded elements
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="example1"><label for="example1"><strong>Find requested data indices in a superset of loaded elements</strong></label><div class="content">


Specify a requested set of data indices. Use a strided superset of the indices to load data from an HDF5 format data source

::

    indices = [20 12 11 10 30 55];
    loaded = dash.indices.strided(indices);


Find the requested indices in the loaded superset

.. rst-class:: no-margin

::

    keep = dash.indices.keep(indices, loaded)


.. rst-class:: example-output

::

    keep =
          [11     3     2     1    21    46]



.. raw:: html

    </div></section>


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.indices.keep.input.requested:

requested
+++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>requested</strong></label><div class="content">

| *vector*, *linear* *indices*
| Indices of requested data elements within a dataset

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.indices.keep.input.loaded:

loaded
++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input2" checked="checked"><label for="input2"><strong>loaded</strong></label><div class="content">

| *vector*, *linear* *indices*
| Indices of loaded data elements from a dataset

.. raw:: html

    </div></section>


----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.indices.keep.output.keep:

keep
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>keep</strong></label><div class="content">

| *vector*, *linear* *indices*
| Indices of requested data elements within the loaded data set

.. raw:: html

    </div></section>


