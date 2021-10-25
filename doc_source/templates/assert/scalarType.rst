dash.assert.scalarType
======================
Throw error if input is not a scalar of a required data type

----

Syntax
------

.. rst-class:: syntax

| :ref:`dash.assert.scalarType(input, type)  checks if input is scalar and the <dash.assert.scalarType.syntax1>`
| :ref:`dash.assert.scalarType(input, type, name)  uses a custom name for the <dash.assert.scalarType.syntax2>`
| :ref:`dash.assert.scalarType(input, type, name, idHeader)  uses a custom <dash.assert.scalarType.syntax3>`

----

Description
-----------

.. _dash.assert.scalarType.syntax1:

.. rst-class:: syntax

dash.assert.scalarType(:ref:`input <dash.assert.scalarType.input.input>`, :ref:`type <dash.assert.scalarType.input.type>`)  checks if input is scalar and the

required data type. If not, throws an error.


.. _dash.assert.scalarType.syntax2:

.. rst-class:: syntax

dash.assert.scalarType(:ref:`input <dash.assert.scalarType.input.input>`, :ref:`type <dash.assert.scalarType.input.type>`, :ref:`name <dash.assert.scalarType.input.name>`)  uses a custom name for the

input in error messages


.. _dash.assert.scalarType.syntax3:

.. rst-class:: syntax

dash.assert.scalarType(:ref:`input <dash.assert.scalarType.input.input>`, :ref:`type <dash.assert.scalarType.input.type>`, :ref:`name <dash.assert.scalarType.input.name>`, :ref:`idHeader <dash.assert.scalarType.input.idHeader>`)  uses a custom

header for thrown error IDs.


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.assert.scalarType.input.input:

input
+++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>input</strong></label><div class="content">

| The input being tested

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.scalarType.input.type:

type
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input2" checked="checked"><label for="input2"><strong>type</strong></label><div class="content">

| *string scalar* | *empty array*
| The required data type of the input. Use an empty array to not require a data type

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.scalarType.input.name:

name
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input3" checked="checked"><label for="input3"><strong>name</strong></label><div class="content">

| *string scalar*
| The name of the input in the calling function. Default is "input"

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.scalarType.input.idHeader:

idHeader
++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input4" checked="checked"><label for="input4"><strong>idHeader</strong></label><div class="content">

| *string scalar*
| Header for thrown error IDs. Default is "DASH:assert:scalarType"

.. raw:: html

    </div></section>



