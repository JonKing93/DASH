dash.dataSource.hdf.setVariable
===============================
Ensure variable exists in HDF file

----

Syntax
------

.. rst-class:: syntax

| :ref:`obj = obj.setVariable(var, fileVars) <dash.dataSource.hdf.setVariable.syntax1>`

----

Description
-----------

.. _dash.dataSource.hdf.setVariable.syntax1:

.. rst-class:: syntax

:ref:`obj <dash.dataSource.hdf.setVariable.output.obj>` = obj.setVariable(:ref:`var <dash.dataSource.hdf.setVariable.input.var>`, :ref:`fileVars <dash.dataSource.hdf.setVariable.input.fileVars>`)

Checks that a variable being loaded is in the list of variables in a HDF file. If not, throws an error. If so, saves the variable name.


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.dataSource.hdf.setVariable.input.var:

var
+++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>var</strong></label><div class="content">

| *string* *scalar*
| Name of the variable to load from the file

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.dataSource.hdf.setVariable.input.fileVars:

fileVars
++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input2" checked="checked"><label for="input2"><strong>fileVars</strong></label><div class="content">

| *string* *vector*
| List of variables in the file

.. raw:: html

    </div></section>


----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.dataSource.hdf.setVariable.output.obj:

obj
+++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>obj</strong></label><div class="content">

| Updated with the saved variable name

.. raw:: html

    </div></section>


