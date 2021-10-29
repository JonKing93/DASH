dash.assert.strsInList
======================
Throw error if strings are not in a list of allowed strings

----

Syntax
------

.. rst-class:: syntax

| :ref:`k = dash.assert.strsInList(strings, list) <dash.assert.strsInList.syntax1>`
| :ref:`k = dash.assert.strsInList(strings, list, name, listName) <dash.assert.strsInList.syntax2>`
| :ref:`k = dash.assert.strsInList(strings, list, name, listName, idHeader) <dash.assert.strsInList.syntax3>`

----

Description
-----------

.. _dash.assert.strsInList.syntax1:

.. rst-class:: syntax

:ref:`k <dash.assert.strsInList.output.k>` = dash.assert.strsInList(:ref:`strings <dash.assert.strsInList.input.strings>`, :ref:`list <dash.assert.strsInList.input.list>`)

Checks if all elements in strings are members of list. If not, throws an error. If so, returns the indices of each string in the list.


.. _dash.assert.strsInList.syntax2:

.. rst-class:: syntax

:ref:`k <dash.assert.strsInList.output.k>` = dash.assert.strsInList(:ref:`strings <dash.assert.strsInList.input.strings>`, :ref:`list <dash.assert.strsInList.input.list>`, :ref:`name <dash.assert.strsInList.input.name>`, :ref:`listName <dash.assert.strsInList.input.listName>`)

Use custom names for the strings and list in the thrown error message.


.. _dash.assert.strsInList.syntax3:

.. rst-class:: syntax

:ref:`k <dash.assert.strsInList.output.k>` = dash.assert.strsInList(:ref:`strings <dash.assert.strsInList.input.strings>`, :ref:`list <dash.assert.strsInList.input.list>`, :ref:`name <dash.assert.strsInList.input.name>`, :ref:`listName <dash.assert.strsInList.input.listName>`, :ref:`idHeader <dash.assert.strsInList.input.idHeader>`)

Use a custom header in thrown error IDs.


----

Examples
--------

.. rst-class:: collapse-examples

Assert strings are members of a list
++++++++++++++++++++++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="example1"><label for="example1"><strong>Assert strings are members of a list</strong></label><div class="content">


Example that passes the assertion:

::

    list = ["here","is","an","example","list"];
    strings = ["an", "here", "list"];
    
    dash.assert.strsInList(strings, list)



Example that fails the assertion

.. rst-class:: no-margin

::

    list = ["here","is","an","example","list"];
    strings = ["different", "strings"];
    
    dash.assert.strsInList(strings, list)


.. rst-class:: example-output error-message 

::

    Element 1 in strings ("different") is not a(n) value in the list. Allowed values are "here","is","an","example", and "list".



.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

Return indices of strings in the list
+++++++++++++++++++++++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="example2"><label for="example2"><strong>Return indices of strings in the list</strong></label><div class="content">


If the assert passes, the function returns the index of each string in the list:

.. rst-class:: no-margin

::

    list = ["A","B","C","D","E"];
    strings = ["C","A","B","B"];
    
    indices = dash.assert.strsInList(strings, list)


.. rst-class:: example-output

::

    indices =
             [3     1     2     2]




.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

Customize error message
+++++++++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="example3"><label for="example3"><strong>Customize error message</strong></label><div class="content">


Customize the error message so it appears to originate from a calling function:

.. rst-class:: no-margin

::

    stringsName = "my strings";
    listName = "allowed list value";
    idHeader = "my:error:header";
    
    list = ["allowed","values"];
    strings = ["not","in","the","list"];
    
    dash.assert.strsInList(strings, list, stringsName, listName, idHeader)


.. rst-class:: example-output error-message 

::

    Element 1 of my strings ("not") is not a(n) allowed list value. Allowed values are "allowed", and "values"




.. raw:: html

    </div></section>


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.assert.strsInList.input.strings:

strings
+++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>strings</strong></label><div class="content">

| *string* *vector*)[*nStrings*
| The set of strings being checked

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.strsInList.input.list:

list
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input2" checked="checked"><label for="input2"><strong>list</strong></label><div class="content">

| *string* *vector*
| The set of allowed strings

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.strsInList.input.name:

name
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input3" checked="checked"><label for="input3"><strong>name</strong></label><div class="content">

| *string* *scalar*
| The name of strings in the calling function. Default is "strings"

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.strsInList.input.listName:

listName
++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input4" checked="checked"><label for="input4"><strong>listName</strong></label><div class="content">

| *string* *scalar*
| The name of list in the calling function. Default is "value in the list"

.. raw:: html

    </div></section>



.. rst-class:: collapse-examples

.. _dash.assert.strsInList.input.idHeader:

idHeader
++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input5" checked="checked"><label for="input5"><strong>idHeader</strong></label><div class="content">

| *string* *scalar*
| A header for thrown error IDs. Default is "DASH:assert:strsInList"

.. raw:: html

    </div></section>


----

Output Arguments
----------------

.. rst-class:: collapse-examples

.. _dash.assert.strsInList.output.k:

k
+

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="output1" checked="checked"><label for="output1"><strong>k</strong></label><div class="content">

| *vector*, *linear* *indices*)[*nStrings*
| The index of each element of strings in the list of allowed values

.. raw:: html

    </div></section>


