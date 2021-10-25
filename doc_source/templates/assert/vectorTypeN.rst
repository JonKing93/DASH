dash.assert.vector
==================
Throws error if input is not a vector of a specified format

----

Syntax
------

.. rst-class:: syntax

| :ref:`dash.assert.vectorTypeN(input, type, length) <dash.assert.vector.syntax1>`
| :ref:`dash.assert.vectorTypeN(input, type, length, name) <dash.assert.vector.syntax2>`
| :ref:`dash.assert.vectorTypeN(input, type, length, name, idHeader) <dash.assert.vector.syntax3>`

----

Description
-----------

.. _dash.assert.vector.syntax1:

.. rst-class:: syntax

dash.assert.vectorTypeN(:ref:`input <dash.assert.vector.input.input>`, :ref:`type <dash.assert.vector.input.type>`, :ref:`length <dash.assert.vector.input.length>`)

Checks if an input is a vector of the required data type and length. If not, throws an error


.. _dash.assert.vector.syntax2:

.. rst-class:: syntax

dash.assert.vectorTypeN(:ref:`input <dash.assert.vector.input.input>`, :ref:`type <dash.assert.vector.input.type>`, :ref:`length <dash.assert.vector.input.length>`, :ref:`name <dash.assert.vector.input.name>`)

Use a custom name to refer to the input in error messages.


.. _dash.assert.vector.syntax3:

.. rst-class:: syntax

dash.assert.vectorTypeN(:ref:`input <dash.assert.vector.input.input>`, :ref:`type <dash.assert.vector.input.type>`, :ref:`length <dash.assert.vector.input.length>`, :ref:`name <dash.assert.vector.input.name>`, :ref:`idHeader <dash.assert.vector.input.idHeader>`)

Use a custom header for thrown error IDs.


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.assert.vector.input.input:

input
+++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>input</strong></label><div class="content">

| The input being tested

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.vector.input.type:

type
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input2" checked="checked"><label for="input2"><strong>type</strong></label><div class="content">

| *string scalar* | *empty array*
| The required data type of the input. Use an empty array to allow any type

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.vector.input.length:

length
++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input3" checked="checked"><label for="input3"><strong>length</strong></label><div class="content">

| *scalar positive integer* | *empty array*
| The required length of the vector. Use an empty array to allow any length

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.vector.input.name:

name
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input4" checked="checked"><label for="input4"><strong>name</strong></label><div class="content">

| *string scalar*
| The name of the input in the calling function for use in error messages. Default is "input"

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.vector.input.idHeader:

idHeader
++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input5" checked="checked"><label for="input5"><strong>idHeader</strong></label><div class="content">

| *string scalar*
| Header for thrown error IDs. Default is "DASH:assert:vectorTypeN"

.. raw:: html

    </div></section>



