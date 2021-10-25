dash.assert.strflag
===================
Throw error if input is not a string flag.

----

Syntax
------

.. rst-class:: syntax

| :ref:`str = dash.assert.strflag(input) <syntax1>`
| :ref:`str = dash.assert.strflag(input, name) <syntax2>`
| :ref:`str = dash.assert.strflag(input, name, idHeader) <syntax3>`

----

Description
-----------

.. _syntax1:

.. rst-class:: syntax

:ref:`str <str>` = dash.assert.strflag(:ref:`input`)

Checks if an input is either a string scalar or char row vector. If not, throws an error. If so, returns the input as a string data type.

Here is a second paragraph


.. _syntax2:

.. rst-class:: syntax

:ref:`str <str>` = dash.assert.strflag(:ref:`input`, :ref:`name`)

Refers to the input by a custom name in thrown error messages.


.. _syntax3:

.. rst-class:: syntax

:ref:`str <str>` = dash.assert.strflag(:ref:`input`, :ref:`name`, :ref:`idHeader`)

Uses a custom header for thrown error IDs

----

Examples (Style 1)
------------------

.. rst-class:: example-header

Assert input is strflag
+++++++++++++++++++++++


Example inputs that pass the assertion::

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

----

.. rst-class:: example-header

Customize error
+++++++++++++++

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

----

.. rst-class:: example-header

Convert input to string
+++++++++++++++++++++++

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

----


.. rst-class: collapse-examples

Examples (Style 2)
------------------

.. rst-class:: collapse-examples

Assert input is strflag
+++++++++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="handle1"><label for="handle1">Assert input is strflag</label><div class="content">

Example inputs that pass the assertion::

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





.. rst-class:: collapse-examples

Customize Error
+++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="handle2"><label for="handle2">Customize Error</label><div class="content">

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

    <section class="accordion"><input type="checkbox" name="collapse" id="handle3"><label for="handle3">Convert input to string</label><div class="content">

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

----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _input:

input
+++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="handle4"><label for="handle4"><strong>input</strong></label><div class="content">

| The input being tested.

.. raw:: html

    </div></section>


.. rst-class:: collapse-examples

.. _name:

name
+++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="handle5"><label for="handle5"><strong>name</strong></label><div class="content">

| 1 | 2 | 3
| Options for matching gridfile metadata and sizes.

[1 (default)]: requires data dimensions to have compatible sizes AND have the same metadata along each non-singleton dimension. Does arithmetic on all data elements.

[2]: Searches for data elements with matching elements in non-singleton dimensions. Only does arithmetic at these elements. Does not require data dimensions to have compatible sizes.

[3]: Does not compare dimensional metadata. Loads all data elements from both files and applies arithmetic directly. Requires data dimensions to have compatible sizes.

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _idHeader:

idHeader
++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="handle6"><label for="handle6"><strong>idHeader</strong></label><div class="content">

| *string scalar*
| Header of thrown error IDs. Default is "DASH:assert:strflag"

.. raw:: html

    </div></section>

----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _str:

str
+++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="handle7"><label for="handle7"><strong>str</strong></label><div class="content">

| *string scalar*
| The input as a string scalar

.. raw:: html

    </div></section>
