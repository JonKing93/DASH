dash.dataSource.mat.toggleWarning
=================================
Change the state of the v7.3 matfile warning.

----

Syntax
------

.. rst-class:: syntax

| :ref:`reset = obj.toggleWarning(state) <dash.dataSource.mat.toggleWarning.syntax1>`

----

Description
-----------

.. _dash.dataSource.mat.toggleWarning.syntax1:

.. rst-class:: syntax

:ref:`reset <dash.dataSource.mat.toggleWarning.output.reset>` = obj.toggleWarning(:ref:`state <dash.dataSource.mat.toggleWarning.input.state>`)

Toggles the state of the Old-Format Mat-File warning to a specified state. Returns a cleanup object that will reset the warning to its initial state when the object is destroyed.


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.dataSource.mat.toggleWarning.input.state:

state
+++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>state</strong></label><div class="content">

| "*on*" | "*off*" | "*error*"
| Desired state of the warning.

.. raw:: html

    </div></section>


----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.dataSource.mat.toggleWarning.output.reset:

reset
+++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>reset</strong></label><div class="content">

| *onCleanup* *object*
| An object that resets the initial state of warning when destroyed

.. raw:: html

    </div></section>


