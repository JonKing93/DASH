dash.indices.strided
====================
Equally spaced indices that include all input indices

----

Syntax
------

.. rst-class:: syntax

| :ref:`B = dash.indices.strided(A) <dash.indices.strided.syntax1>`

----

Description
-----------

.. _dash.indices.strided.syntax1:

.. rst-class:: syntax

:ref:`B <dash.indices.strided.output.B>` = dash.indices.strided(:ref:`A <dash.indices.strided.input.A>`)

Returns a set of equally spaced, monotonically increasing indices (B) that contain all linear indices specified in A.


----

Examples
--------

.. rst-class:: collapse-examples

Get strided indices that include requested indices
++++++++++++++++++++++++++++++++++++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="example1"><label for="example1"><strong>Get strided indices that include requested indices</strong></label><div class="content">


Data stored in HDF5 formatted files is accessed using strided (evenly spaced) indices, so it is often useful to find a strided set of data indices that includes requested data elements. In this way, the loaded data will include the requested dataset.

Get a strided superset of indices:

.. rst-class:: no-margin

::

    indices = [8 4 10 12];
    strided = dash.indices.strided(indices)


.. rst-class:: example-output

::

    strided =
             [4     5     6     7     8     9    10    11    12]



.. raw:: html

    </div></section>


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.indices.strided.input.A:

A
+

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>A</strong></label><div class="content">

| *vector*, *linear* *indices*
| A set of indices that the strided output must include.

.. raw:: html

    </div></section>


----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.indices.strided.output.B:

B
+

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>B</strong></label><div class="content">

| *vector*, *linear* *indices*
| Equally spaced set of indices that includes all indices in A

.. raw:: html

    </div></section>


