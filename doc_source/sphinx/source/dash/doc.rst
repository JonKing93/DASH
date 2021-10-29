dash.doc
========
Open online reference page in a web browser.

----

Syntax
------

.. rst-class:: syntax

| :ref:`dash.doc(name) <dash.doc.syntax1>`
| :ref:`>> dash.doc( "dash.is.strflag" ) <dash.doc.syntax2>`
| :ref:`>> dash.doc( "kalmanFilter" ) <dash.doc.syntax3>`
| :ref:`>> dash.doc( "kalmanFilter.prior" ) <dash.doc.syntax4>`

----

Description
-----------

.. _dash.doc.syntax1:

.. rst-class:: syntax

dash.doc(:ref:`name <dash.doc.input.name>`)

Opens the online reference page for a method, package, or class in the DASH toolbox.

The name of the method, package, or class should include all package/subpackage headers. For example:


.. _dash.doc.syntax2:

.. rst-class:: syntax

>> dash.doc( "dash.is.strflag" )




.. _dash.doc.syntax3:

.. rst-class:: syntax

>> dash.doc( "kalmanFilter" )




.. _dash.doc.syntax4:

.. rst-class:: syntax

>> dash.doc( "kalmanFilter.prior" )




----

Examples
--------

.. rst-class:: collapse-examples

Open documentation pages
++++++++++++++++++++++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="example1"><label for="example1"><strong>Open documentation pages</strong></label><div class="content">


For a class:

::

    dash.doc('gridfile')


For a class method:

::

    dash.doc('gridfile.add')


For a package:

::

    dash.doc('dash.math')


For a function in a package:

::

    dash.doc('dash.math.haversine')

.. raw:: html

    </div></section>


----

Input Arguments
---------------

.. rst-class:: collapse-examples

.. _dash.doc.input.name:

name
++++

.. raw:: html

    <section class="accordion"><input type="checkbox" name="collapse" id="input1" checked="checked"><label for="input1"><strong>name</strong></label><div class="content">

| *string* *scalar*
| The full name of a method, package, or class in the DASH toolbox.

.. raw:: html

    </div></section>


