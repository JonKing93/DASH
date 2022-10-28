Help and Documentation
======================
The DASH toolbox includes comprehensive documentation for every class and command. There are several ways to access this documentation.


Console Help Text
-----------------
You can display help text for components of the DASH toolbox using Matlab's built-in ``help`` command. To print the help text, enter ``help``, followed by the name of the DASH component, in the console. For example::

    help kalmanFilter

will display the help text for the ``kalmanFilter`` class.

To display help text for a specific function or method, use the full dot-indexing title of the method. For example, to display help for the ``run`` method of the ``kalmanFilter`` class, use::

    help kalmanFilter.run



Reference Guide
---------------
The DASH documentation also includes an HTML reference guide for every class and command in the toolbox. This reference guide is essentially an offline website - the reference guide will open in an internet browser, but does not require an internet connection to use. The reference guide is more comprehensive than the console help text, and it includes additional information such as usage examples, experiment demos, and tutorials.

There are several ways to access the reference guide. The first is using the ``dash.doc`` command. Entering::

    dash.doc

in the Matlab console will open the reference guide at its first page. Alternatively, you can open the documentation page for a particular class or method by using the class or method name as the first input. For example::

    dash.doc('kalmanFilter')

will open the documentation page for the ``kalmanFilter`` class, and::

    dash.doc('kalmanFilter.run')

will open the documentation page for the ``run`` method.

Alternatively, you can open specific documentation pages by clicking on the **"Documentation Page"** hyperlink at the end of console help text.



A note on syntax
----------------
Most of the commands in the DASH toolbox are :ref:`class methods <classes>` that act on individual :ref:`objects <objects>`. For example, we previously discussed how we could call the ``run`` method on different ``kalmanFilter`` objects to run the algorithm for different experimental parameters. In the documentation of these commands, you will often see the syntax ``obj.<method name>``, where ``<method name>`` is the name of the command. This indicates that you should call the command using dot-indexing from individual *objects*.

For example, in the documentation ``kalmanFilter.run``, the command syntax is listed as::

    output = obj.run

The ``obj`` prefix indicates that you should call the ``run`` command on individual ``kalmanFilter`` objects. For example::

    objectA = kalmanFilter('Experiment A');
    outputA = objectA.run

or similarly::

    objectB = kalmanFilter('Experiment B');
    outputB = objectB.run
