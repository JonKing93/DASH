dash.assert.strflag
===================
Throw error if input is not a string flag.

----

Syntax
------

.. rst-class:: syntax

| :ref:`str = dash.assert.strflag(input) <dash.assert.strflag.syntax1>`
| :ref:`str = dash.assert.strflag(input, name) <dash.assert.strflag.syntax2>`
| :ref:`str = dash.assert.strflag(input, name, idHeader) <dash.assert.strflag.syntax3>`

----

Description
-----------

.. _dash.assert.strflag.syntax1:

.. rst-class:: syntax

:ref:`str <dash.assert.strflag.output.str>` = dash.assert.strflag(:ref:`input <dash.assert.strflag.input.input>`)

Checks if an input is either a string scalar or char row vector. If not, throws an error. If so, returns the input as a string data type.

Here is a second paragraph with information about the function.


.. _dash.assert.strflag.syntax2:

.. rst-class:: syntax

:ref:`str <dash.assert.strflag.output.str>` = dash.assert.strflag(:ref:`input <dash.assert.strflag.input.input>`, :ref:`name <dash.assert.strflag.input.name>`)

Refers to the input by a custom name in thrown error messages.


.. _dash.assert.strflag.syntax3:

.. rst-class:: syntax

:ref:`str <dash.assert.strflag.output.str>` = dash.assert.strflag(:ref:`input <dash.assert.strflag.input.input>`, :ref:`name <dash.assert.strflag.input.name>`, :ref:`idHeader <dash.assert.strflag.input.idHeader>`)

Uses a custom header for thrown error IDs.


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.assert.strflag.input.input:

input
+++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>input</strong></label><div class="content">

| The input being tested

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.strflag.input.name:

name
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input2" checked="checked"><label for="input2"><strong>name</strong></label><div class="content">

| *string scalar*
| Name of the input in the calling function. Default is "input".

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.strflag.input.idHeader:

idHeader
++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input3" checked="checked"><label for="input3"><strong>idHeader</strong></label><div class="content">

| *string scalar*
| Header for thrown error IDs. Default is "DASH:assert:strflag".

.. raw:: html

    </div></section>



----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.assert.strflag.output.str:

str
+++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>str</strong></label><div class="content">

| *string scalar*
| The input converted to a string data type.

.. raw:: html

    </div></section>



