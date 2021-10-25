dash.assert.fileExists
======================
Throw error if a file does not exist

----

Syntax
------

.. rst-class:: syntax

| :ref:`abspath = dash.assert.fileExists(filename) <dash.assert.fileExists.syntax1>`
| :ref:`abspath = dash.assert.fileExists(filename, ext) <dash.assert.fileExists.syntax2>`
| :ref:`abspath = dash.assert.fileExists(filename, ext, idHeader) <dash.assert.fileExists.syntax3>`

----

Description
-----------

.. _dash.assert.fileExists.syntax1:

.. rst-class:: syntax

:ref:`abspath <dash.assert.fileExists.output.abspath>` = dash.assert.fileExists(:ref:`filename <dash.assert.fileExists.input.filename>`)

Checks if a file exists. If not, throws an error. If so, returns the absolute path to the file as a string.


.. _dash.assert.fileExists.syntax2:

.. rst-class:: syntax

:ref:`abspath <dash.assert.fileExists.output.abspath>` = dash.assert.fileExists(:ref:`filename <dash.assert.fileExists.input.filename>`, :ref:`ext <dash.assert.fileExists.input.ext>`)

Also checks for files with the given extension.


.. _dash.assert.fileExists.syntax3:

.. rst-class:: syntax

:ref:`abspath <dash.assert.fileExists.output.abspath>` = dash.assert.fileExists(:ref:`filename <dash.assert.fileExists.input.filename>`, :ref:`ext <dash.assert.fileExists.input.ext>`, :ref:`idHeader <dash.assert.fileExists.input.idHeader>`)

Uses a custom header in thrown error IDs.


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.assert.fileExists.input.filename:

filename
++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>filename</strong></label><div class="content">

| *string scalar*
| The name of a file

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.fileExists.input.ext:

ext
+++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input2" checked="checked"><label for="input2"><strong>ext</strong></label><div class="content">

| *string scalar* | *empty array*
| Default file extension. Leave unset, or use an empty array to not check extensions.

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.fileExists.input.idHeader:

idHeader
++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input3" checked="checked"><label for="input3"><strong>idHeader</strong></label><div class="content">

| *string scalar*
| Header to use in thrown error IDs. Default is "DASH:assert:fileExists"

.. raw:: html

    </div></section>



----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.assert.fileExists.output.abspath:

abspath
+++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>abspath</strong></label><div class="content">

| *string scalar*
| The absolute path to the file

.. raw:: html

    </div></section>



