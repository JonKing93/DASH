dash.string.list
================
List the elements of a vector in a formatted sting

----

Syntax
------

.. rst-class:: syntax

| :ref:`string = dash.string.list(list) <dash.string.list.syntax1>`

----

Description
-----------

.. _dash.string.list.syntax1:

.. rst-class:: syntax

:ref:`string <dash.string.list.output.string>` = dash.string.list(list)

Rrints the elements of a vector in a string. In the returned string, elements are separated by commas and the word "and" is placed before the final element, if appropriate.


----

Examples
--------

.. rst-class:: collapse-examples

Lists with 1, 2, or 3+ elements
+++++++++++++++++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="example1"><label for="example1"><strong>Lists with 1, 2, or 3+ elements</strong></label><div class="content">


With one element:

.. rst-class:: no-margin

::

    list = dash.string.list("value1")


.. rst-class:: example-output

::

    list =
          "value1"


With 2 elements

.. rst-class:: no-margin

::

    list = dash.string.list(["value1", "value2"])


.. rst-class:: example-output

::

    list = 
          "value1 and value2"


With 3+ elements:

.. rst-class:: no-margin

::

    list = dash.string.list(["v1","v2","v3","v4"])


.. rst-class:: example-output

::

    list = 
          "v1, v2, v3, and v4"



.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

Lists of integers
+++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="example2"><label for="example2"><strong>Lists of integers</strong></label><div class="content">


.. rst-class:: no-margin

::

    list = dash.string.list([1 2 3 4 5])


.. rst-class:: example-output

::

    list =
          "1, 2, 3, 4, and 5"

.. raw:: html

    </div></section>


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.string.list.input.vector:

vector
++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>vector</strong></label><div class="content">

| *string* *array* | *integer* *array*
| The list being converted to a string

.. raw:: html

    </div></section>


----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.string.list.output.string:

string
++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>string</strong></label><div class="content">

| *string* *scalar*
| The elements of the list formatted as a string

.. raw:: html

    </div></section>


