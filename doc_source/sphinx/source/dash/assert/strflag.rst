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

Examples
--------

.. rst-class:: collapse-examples

Assert input is strflag
+++++++++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="example1"><label for="example1"><strong>Assert input is strflag</strong></label><div class="content">


Example inputs that pass the assertion:

.. rst-class:: no-margin

::

    dash.assert.strflag("A string scalar")
    dash.assert.strflag('A char row vector')


Example inputs that fail the assertion:

.. rst-class:: no-margin

::

    dash.assert.strflag(5)
    dash.assert.strflag(true)
    dash.assert.strflag({'A cellstring scalar'})
    dash.assert.strflag(["A","string","vector"])


.. rst-class:: example-output error-message 

::

    input must be a string scalar or character row vector



.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

Customize Error
+++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="example2"><label for="example2"><strong>Customize Error</strong></label><div class="content">


Customize the error message so it mimics errors from a calling function:

.. rst-class:: no-margin

::

    name = 'my variable';
    header = 'myHeader';
    dash.assert.strflag(5, name, header);


.. rst-class:: example-output error-message 

::

    my variable must be a string scalar or character row vector


Examine the error ID:

.. rst-class:: no-margin

::

    ME = lasterror;
    ID = ME.identifier


.. rst-class:: example-output

::

    ID =
        myHeader:inputNotStrflag



.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

Convert input to string
+++++++++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="example3"><label for="example3"><strong>Convert input to string</strong></label><div class="content">


If the assertion passes, the input is returned as a scalar string. Use this to allow for a single data type (string) in subsequent code. For example:

.. rst-class:: no-margin

::

    input = 'A char row vector';
    str = dash.assert.strflag(input);
    type = class(str)


.. rst-class:: example-output

::

    type =
          'string'


The char input has been converted to a string data type.

.. raw:: html

    </div></section>


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

| *string* *scalar*
| Name of the input in the calling function. Default is "input".

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.strflag.input.idHeader:

idHeader
++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input3" checked="checked"><label for="input3"><strong>idHeader</strong></label><div class="content">

| *string* *scalar*
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

| *string* *scalar*
| The input converted to a string data type.

.. raw:: html

    </div></section>


