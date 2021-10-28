dash.metadata.assert
====================
Throw error if input is not a valid metadata structure

----

Syntax
------

.. rst-class:: syntax

| :ref:`meta = dash.metadata.assert(meta, dimsList, idHeader) <dash.metadata.assert.syntax1>`

----

Description
-----------

.. _dash.metadata.assert.syntax1:

.. rst-class:: syntax

:ref:`meta <dash.metadata.assert.output.meta>` = dash.metadata.assert(:ref:`meta <dash.metadata.assert.input.meta>`, :ref:`dimsList <dash.metadata.assert.input.dimsList>`, :ref:`idHeader <dash.metadata.assert.input.idHeader>`)

Checks if meta is a valid metadata structure. If not, throws an error with custom error message and identifier. If so, converts cellstring metadata fields to string.

Valid metadata structures are a scalar structure, only have allowed dimension names, and all fields are valid metadata fields.


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.metadata.assert.input.meta:

meta
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>meta</strong></label><div class="content">

| The metadata structure being tested

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.metadata.assert.input.dimsList:

dimsList
++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input2" checked="checked"><label for="input2"><strong>dimsList</strong></label><div class="content">

| *string* *vector*
| A list of allowed dimension names

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.metadata.assert.input.idHeader:

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

.. _dash.metadata.assert.output.meta:

meta
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>meta</strong></label><div class="content">

| The metadata structure with cellstring metadata fields converted to the string data type.

.. raw:: html

    </div></section>


