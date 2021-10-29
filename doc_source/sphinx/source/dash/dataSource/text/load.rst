dash.dataSource.text.load
=========================
Load data from a delimited text file

----

Syntax
------

.. rst-class:: syntax

| :ref:`X = obj.load(indices) <dash.dataSource.text.load.syntax1>`

----

Description
-----------

.. _dash.dataSource.text.load.syntax1:

.. rst-class:: syntax

:ref:`X <dash.dataSource.text.load.output.X>` = obj.load(:ref:`indices <dash.dataSource.text.load.input.indices>`)

Loads data from a delimited text at the specified linear indices.


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.dataSource.text.load.input.indices:

indices
+++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>indices</strong></label><div class="content">

| *cell* *vector* [*nDims*] {*vector*, *linear* *indices*}
| The indices of data elements along each dimension to load from the text file. Should have one element per dimension of the variable. Each element holds a vector of linear indices.

.. raw:: html

    </div></section>


----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.dataSource.text.load.output.X:

X
+

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>X</strong></label><div class="content">

| *array*
| The loaded data

.. raw:: html

    </div></section>


