dash.dataSource.text.text
=========================
Create a new dash.dataSource.text object

----

Syntax
------

.. rst-class:: syntax

| :ref:`obj = dash.dataSource.text(file) <dash.dataSource.text.text.syntax1>`
| :ref:`obj = dash.dataSource.text(..., opts) <dash.dataSource.text.text.syntax2>`
| :ref:`obj = dash.dataSource.text(..., Name, Value) <dash.dataSource.text.text.syntax3>`

----

Description
-----------

.. _dash.dataSource.text.text.syntax1:

.. rst-class:: syntax

:ref:`obj <dash.dataSource.text.text.output.obj>` = dash.dataSource.text(:ref:`file <dash.dataSource.text.text.input.file>`)

Creates an object to read data from a delimited text file


.. _dash.dataSource.text.text.syntax2:

.. rst-class:: syntax

:ref:`obj <dash.dataSource.text.text.output.obj>` = dash.dataSource.text(..., :ref:`opts <dash.dataSource.text.text.input.opts>`)

Reads data from the file using the provided ImportOptions object


.. _dash.dataSource.text.text.syntax3:

.. rst-class:: syntax

:ref:`obj <dash.dataSource.text.text.output.obj>` = dash.dataSource.text(..., Name, Value)

Specifies additional import options using name-value pair arguments. Supported Name-Value pairs are those in Matlab's "readmatrix" function. See the documentation page for "readmatrix" for details.


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.dataSource.text.text.input.file:

file
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>file</strong></label><div class="content">

| *string* *scalar*
| The name of a delimited text file

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.dataSource.text.text.input.opts:

opts
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input2" checked="checked"><label for="input2"><strong>opts</strong></label><div class="content">

| *ImportOptions*
| Additional options for importing data from the file

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.dataSource.text.text.input.Name,Value:

Name,Value
++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input3" checked="checked"><label for="input3"><strong>Name,Value</strong></label><div class="content">

| Additional import options for reading data from the file. Supported pairs are those for the "readmatrix" function

.. raw:: html

    </div></section>


----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.dataSource.text.text.output.obj:

obj
+++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>obj</strong></label><div class="content">

| The new dash.dataSource.text object

.. raw:: html

    </div></section>


