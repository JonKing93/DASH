Object-Oriented Code
====================
DASH is written in an object-oriented programming (OOP) style, which allows the toolbox to be separated into different components. DASH users do not need to be familiar with OOP to use the toolbox. However, we use a few OOP terms throughout the workshop, and so we define them here. We also introduce dot-indexing, which is how DASH users will access different functions in the toolbox. A :ref:`glossary <glossary>` of new vocabulary is provided at the bottom of the page.


Learning Objectives
-------------------
1. Define classes and objects, and
2. Introduce dot-indexing



.. _classes:

Classes
-------
The DASH toolbox is written in an object-oriented style. This means that the toolbox is divided into components called **classes**. A class is a piece of code that describes a specialized structure - this structure will have some data fields, and also some functions that operate using those data fields. The data fields are known as **properties**, and the functions are known as **methods**.

For example, DASH includes a ``kalmanFilter`` class, which helps implement the Kalman filter algorithm. This class has various data fields (properties), such as the ensemble prior and the observations / proxy records. The class also includes various functions (methods) that help to run an ensemble Kalman filter. For example, the ``kalmanFilter`` class includes a ``localize`` method, which implements covariance localization, and a ``run`` method, which runs the Kalman filter algorithm.


.. _objects:

Objects
-------
An **object** is a specific instance of a class. Essentially, a class is the blueprint of a structure, and an object is the actual structure itself. To create an object for a particular class, you usually use a function that matches the name of the class. The output of the function is the object. For example, to create a ``kalmanFilter`` object, you would use::

    myObject = kalmanFilter;

The output ``myObject`` is an object that implements the Kalman filter algorithm.

It's important to note that you can create multiple different objects of the same class. These different objects can hold different values in their data fields. For example, to create objects for two separate assimilations, you could do::

    object1 = kalmanFilter('Experiment 1');
    object2 = kalmanFilter('Experiment 2');

Here, objects 1 and 2 could hold data values for two different experiments, and could run the Kalman filter algorithm using different experimental parameters.


Dot Indexing
------------
Dot indexing provides a way for users to:

1. Access an object's data fields, and
2. Call object methods

To use **dot indexing** in a script or console, place a dot ``.`` immediately after the object. To return a data field for the object, place the name of the data field after the dot. For example, the ``kalmanFilter`` class has a data field named ``label``, which stores an optional label for a ``kalmanFilter`` object. Continuing the previous examples, you can return the label for object 1 using::

    object1.label

    "Experiment 1"

Similarly, you can return the label for object 2 using::

    object2.label

    "Experiment 2"


To call one of the object's methods, place the name of the method after the dot. For example, to run the Kalman filter algorithm for experiment 1, you would do::

    object1.run

Remember that methods are essentially functions. Aside from the dot indexing, they use the standard function syntax -- so you can pass additional input arguments to the method using parentheses. For example, if you wanted to run experiment 1 with some extra options, you could do::

    object1.run("Option A", 'some parameter', "Option B", 5)

.. note::

    These options are just for demonstration purposes. They aren't real options for ``kalmanFilter.run``.


.. _glossary:

Glossary
--------

**class**: Describes a specialized structure that has both data fields and functions that operate using those data fields.

**property**: A data field in a class.

**method**: A function for a class.

**object**: A specific instance of a class. Different objects of the same class can have different values in their data fields.

**dot-indexing**: Using a dot . to access the data fields and functions of an object
