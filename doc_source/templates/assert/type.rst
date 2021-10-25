dash.assert.type
================
Throw error if input is not required type

----

Syntax
------

.. rst-class:: syntax

| :ref:`dash.assert.type(input, type)  checks if input is the required data <dash.assert.type.syntax1>`
| :ref:`dash.assert.type(input, type, name, descriptor)  uses a custom name and <dash.assert.type.syntax2>`
| :ref:`dash.assert.type(input, type, name, descriptor, idHeader)  uses a custom <dash.assert.type.syntax3>`

----

Description
-----------

.. _dash.assert.type.syntax1:

.. rst-class:: syntax

dash.assert.type(:ref:`input <dash.assert.type.input.input>`, :ref:`type <dash.assert.type.input.type>`)  checks if input is the required data

type. If not, throws an error.


.. _dash.assert.type.syntax2:

.. rst-class:: syntax

dash.assert.type(:ref:`input <dash.assert.type.input.input>`, :ref:`type <dash.assert.type.input.type>`, :ref:`name <dash.assert.type.input.name>`, :ref:`descriptor <dash.assert.type.input.descriptor>`)  uses a custom name and

data type descriptor in thrown error messages.


.. _dash.assert.type.syntax3:

.. rst-class:: syntax

dash.assert.type(:ref:`input <dash.assert.type.input.input>`, :ref:`type <dash.assert.type.input.type>`, :ref:`name <dash.assert.type.input.name>`, :ref:`descriptor <dash.assert.type.input.descriptor>`, :ref:`idHeader <dash.assert.type.input.idHeader>`)  uses a custom

header in thrown error IDs.


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.assert.type.input.input:

input
+++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>input</strong></label><div class="content">

| The input being tested

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.type.input.type:

type
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input2" checked="checked"><label for="input2"><strong>type</strong></label><div class="content">

| *string scalar*
| The required data type

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.type.input.name:

name
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input3" checked="checked"><label for="input3"><strong>name</strong></label><div class="content">

| *string scalar*
| The name of the input in the calling function for use in error messages. Default is "input"

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.type.input.descriptor:

descriptor
++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input4" checked="checked"><label for="input4"><strong>descriptor</strong></label><div class="content">

| *string scalar*
| Descriptor for data type in error messages. Default is "data type"

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.type.input.idHeader:

idHeader
++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input5" checked="checked"><label for="input5"><strong>idHeader</strong></label><div class="content">

| *string scalar*
| Header for thrown error IDs. Default is "DASH:assert:type"

.. raw:: html

    </div></section>



