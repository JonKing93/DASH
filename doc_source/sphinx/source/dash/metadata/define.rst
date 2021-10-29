dash.metadata.define
====================
Creates a metadata structure for a gridded dataset

----

Syntax
------

.. rst-class:: syntax

| :ref:`meta = dash.metadata.define(dim1, meta1, dim2, meta2, ..., dimN, metaN) <dash.metadata.define.syntax1>`

----

Description
-----------

.. _dash.metadata.define.syntax1:

.. rst-class:: syntax

:ref:`meta <dash.metadata.define.output.meta>` = dash.metadata.define(dim1, meta1, dim2, meta2, ..., :ref:`dimN <dash.metadata.define.input.dimN>`, :ref:`metaN <dash.metadata.define.input.metaN>`)

Returns a metadata structure for a gridded dataset


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.metadata.define.input.dimN:

dimN
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>dimN</strong></label><div class="content">

| *string* *scalar*
| The name of a dimension of a gridded dataset

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.metadata.define.input.metaN:

metaN
+++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input2" checked="checked"><label for="input2"><strong>metaN</strong></label><div class="content">

| *matrix*, *numeric* | *logical* | *char* | *string* | *cellstring* | *datetime*
| The metadata for the dimension. Cannot have NaN or NaT elements. All rows must be unique.

.. raw:: html

    </div></section>


----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.metadata.define.output.meta:

meta
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>meta</strong></label><div class="content">

| *scalar* *structure*
| The metadata structure for a gridded dataset. The fields of the structure are the input dimension names (dimN). Each field holds the associated metadata field (metaN). Cellstring metadata are converted to string.

.. raw:: html

    </div></section>


