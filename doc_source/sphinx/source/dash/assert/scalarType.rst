dash.assert.scalarType
======================
Throw error if input is not a scalar of a required data type

----

Syntax
------

.. rst-class:: syntax

| :ref:`dash.assert.scalarType(input, type)  checks if input is scalar and the <dash.assert.scalarType.syntax1>`
| :ref:`dash.assert.scalarType(input, type, name)  uses a custom name for the <dash.assert.scalarType.syntax2>`
| :ref:`dash.assert.scalarType(input, type, name, idHeader)  uses a custom <dash.assert.scalarType.syntax3>`

----

Description
-----------

.. _dash.assert.scalarType.syntax1:

.. rst-class:: syntax

dash.assert.scalarType(:ref:`input <dash.assert.scalarType.input.input>`, :ref:`type <dash.assert.scalarType.input.type>`)  checks if input is scalar and the

required data type. If not, throws an error.


.. _dash.assert.scalarType.syntax2:

.. rst-class:: syntax

dash.assert.scalarType(:ref:`input <dash.assert.scalarType.input.input>`, :ref:`type <dash.assert.scalarType.input.type>`, :ref:`name <dash.assert.scalarType.input.name>`)  uses a custom name for the

input in error messages


.. _dash.assert.scalarType.syntax3:

.. rst-class:: syntax

dash.assert.scalarType(:ref:`input <dash.assert.scalarType.input.input>`, :ref:`type <dash.assert.scalarType.input.type>`, :ref:`name <dash.assert.scalarType.input.name>`, :ref:`idHeader <dash.assert.scalarType.input.idHeader>`)  uses a custom

header for thrown error IDs.


----

Examples
--------

.. rst-class:: collapse-examples

Assert input is scalar and required data type
+++++++++++++++++++++++++++++++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="example1"><label for="example1"><strong>Assert input is scalar and required data type</strong></label><div class="content">


Examples that pass the assertion:

::

    dash.assert.scalarType(5, 'numeric')
    dash.assert.scalarType(5, 'float')
    dash.assert.scalarType(false, 'logical')
    dash.assert.scalarType( {rand(4,5)}, 'cell')


Examples that fail the assertion because they are not scalar

.. rst-class:: no-margin

::

    dash.assert.scalarType([5,6,7], 'numeric')
    dash.assert.scalarType(true(5,1), 'logical')


.. rst-class:: example-output error-message 

::

    input is not scalar


Examples that fail because they are the wrong type:

.. rst-class:: no-margin

::

    dash.assert.scalarType({5}, 'numeric')


.. rst-class:: example-output error-message 

::

    input must be a numeric scalar, but it is a cell scalar instead


.. rst-class:: no-margin

::

    dash.assert.scalarType({true}, 'logical')


::

    input must be a logical scalar, but it is a cell scalar instead




.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

Only assert scalar (ignore data type)
+++++++++++++++++++++++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="example2"><label for="example2"><strong>Only assert scalar (ignore data type)</strong></label><div class="content">


Use an empty array as the second input to only assert the input is scalar:

::

    dash.assert.scalarType(5, [])
    dash.assert.scalarType(true, [])
    dash.assert.scalarType("a string", [])




.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

Customize Error
+++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="example3"><label for="example3"><strong>Customize Error</strong></label><div class="content">


Customize the error message to it appears to originate from a calling function:

.. rst-class:: no-margin

::

    inputName = "my variable";
    idHeader = "my:error:header"
    
    dash.assert.scalarType([1 2 3], 'numeric', inputName, idHeader)


.. rst-class:: example-output error-message 

::

    my variable is not scalar


Also examine the error ID:

.. rst-class:: no-margin

::

    ME = lasterror;
    ID = ME.identifier


.. rst-class:: example-output

::

    ID =
        'my:error:header:inputNotScalar'

.. raw:: html

    </div></section>


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.assert.scalarType.input.input:

input
+++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>input</strong></label><div class="content">

| The input being tested

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.scalarType.input.type:

type
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input2" checked="checked"><label for="input2"><strong>type</strong></label><div class="content">

| *string* *scalar* | *empty* *array*
| The required data type of the input. Use an empty array to not require a data type

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.scalarType.input.name:

name
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input3" checked="checked"><label for="input3"><strong>name</strong></label><div class="content">

| *string* *scalar*
| The name of the input in the calling function. Default is "input"

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.scalarType.input.idHeader:

idHeader
++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input4" checked="checked"><label for="input4"><strong>idHeader</strong></label><div class="content">

| *string* *scalar*
| Header for thrown error IDs. Default is "DASH:assert:scalarType"

.. raw:: html

    </div></section>


