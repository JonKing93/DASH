dash.assert.strlist
===================
Throw error if input is not a string vector, cellstring vector, or char row vector

----

Syntax
------

.. rst-class:: syntax

| :ref:`list = dash.assert.strlist(input) <dash.assert.strlist.syntax1>`
| :ref:`list = dash.assert.strlist(input, name) <dash.assert.strlist.syntax2>`
| :ref:`list = dash.assert.strlist(input, name, idHeader) <dash.assert.strlist.syntax3>`

----

Description
-----------

.. _dash.assert.strlist.syntax1:

.. rst-class:: syntax

:ref:`list <dash.assert.strlist.output.list>` = dash.assert.strlist(:ref:`input <dash.assert.strlist.input.input>`)

Checks if input is a string vector, cellstring vector, or char row vector. If so, returns the input as a string vector. If not, throws an error.


.. _dash.assert.strlist.syntax2:

.. rst-class:: syntax

:ref:`list <dash.assert.strlist.output.list>` = dash.assert.strlist(:ref:`input <dash.assert.strlist.input.input>`, :ref:`name <dash.assert.strlist.input.name>`)

Use a custom name to refer to variable in the error message.


.. _dash.assert.strlist.syntax3:

.. rst-class:: syntax

:ref:`list <dash.assert.strlist.output.list>` = dash.assert.strlist(:ref:`input <dash.assert.strlist.input.input>`, :ref:`name <dash.assert.strlist.input.name>`, :ref:`idHeader <dash.assert.strlist.input.idHeader>`)

Use a custom header for thrown error IDs.


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.assert.strlist.input.input:

input
+++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>input</strong></label><div class="content">

| The input being tested

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.strlist.input.name:

name
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input2" checked="checked"><label for="input2"><strong>name</strong></label><div class="content">

| *string scalar*
| The name of the input in the calling function. Default is "input"

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.strlist.input.idHeader:

idHeader
++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input3" checked="checked"><label for="input3"><strong>idHeader</strong></label><div class="content">

| *string scalar*
| A header for thrown error IDs. Default is "DASH:assert:strlist"

.. raw:: html

    </div></section>



----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.assert.strlist.output.list:

list
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>list</strong></label><div class="content">

| *string vector*
| The input converted to string data type

.. raw:: html

    </div></section>



