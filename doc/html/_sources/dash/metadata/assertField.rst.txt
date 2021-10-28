dash.metadata.assertField
=========================
Throw error if input is not a valid metadata field

----

Syntax
------

.. rst-class:: syntax

| :ref:`meta = dash.metadata.assertField(meta, dim, idHeader) <dash.metadata.assertField.syntax1>`

----

Description
-----------

.. _dash.metadata.assertField.syntax1:

.. rst-class:: syntax

:ref:`meta <dash.metadata.assertField.output.meta>` = dash.metadata.assertField(:ref:`meta <dash.metadata.assertField.input.meta>`, :ref:`dim <dash.metadata.assertField.input.dim>`, :ref:`idHeader <dash.metadata.assertField.input.idHeader>`)

Checks if meta is a valid metadata field. If not, throws an error with custom message and identifier. If so and the metadata is cellstring, returns the  metadata as a string matrix.

Valid metadata fields matrices, have no duplicate rows, and are one of the following data type: numeric, logical, char, string, cellstring, or datetime.


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.metadata.assertField.input.meta:

meta
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>meta</strong></label><div class="content">

| The metadata input being tested

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.metadata.assertField.input.dim:

dim
+++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input2" checked="checked"><label for="input2"><strong>dim</strong></label><div class="content">

| *string* *scalar*
| The name of the dimension associated with the metadata

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.metadata.assertField.input.idHeader:

idHeader
++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input3" checked="checked"><label for="input3"><strong>idHeader</strong></label><div class="content">

| *string* *scalar*
| Header for thrown error IDs

.. raw:: html

    </div></section>


----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.metadata.assertField.output.meta:

meta
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>meta</strong></label><div class="content">

| The metadata field. If the input value was a cellstring data type, converts it to a string data type.

.. raw:: html

    </div></section>


