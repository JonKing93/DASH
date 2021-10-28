dash.metadata.hasDuplicateRows
==============================
True if a metadata field has duplicate rows

----

Syntax
------

.. rst-class:: syntax

| :ref:`tf = dash.metadata.hasDuplicateRows(meta) <dash.metadata.hasDuplicateRows.syntax1>`

----

Description
-----------

.. _dash.metadata.hasDuplicateRows.syntax1:

.. rst-class:: syntax

:ref:`tf <dash.metadata.hasDuplicateRows.output.tf>` = dash.metadata.hasDuplicateRows(:ref:`meta <dash.metadata.hasDuplicateRows.input.meta>`)

Returns true if meta has duplicate rows and false otherwise


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.metadata.hasDuplicateRows.input.meta:

meta
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>meta</strong></label><div class="content">

| *matrix* - *numeric* | *logical* | *char* | *string* | *datetime*
| The metadata field being tested

.. raw:: html

    </div></section>


----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.metadata.hasDuplicateRows.output.tf:

tf
++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>tf</strong></label><div class="content">

| *scalar* *logical*
| True if meta has duplicate rows

.. raw:: html

    </div></section>


