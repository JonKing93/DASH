Welcome to the DASH Tutorial!
=============================

About
-----
This tutorial is designed to introduce users to DASH, a Matlab toolbox for paleoclimate data assimilation.  After an initial overview of the DASH toolbox, the tutorial alternates between a series of short lessons and code demos. Each lesson introduces a component of the DASH toolbox and demonstrate its use. The following code demo then gives users an opportunity to practice using that component.

By the end of the tutorial, users should be able to use DASH to implement many types of assimilations. The tutorial is designed to introduce nearly all of the main features of DASH - this likely includes more features than any single user will need, so feel free to skip over sections not relevant to your particular interests. We recommend budgeting several hours to complete the tutorial.


Prerequisites
-------------
You will need to :doc:`install DASH <../installation>` if you want to follow along with the code demos in the tutorial.


Workshop Recordings
-------------------
We ran a DASH workshop in October 2022 that worked through a partial version of this tutorial. If helpful, you can find recordings of the workshop here: `Workshop Recordings`_

.. _Workshop Recordings: https://www.youtube.com/playlist?list=PL5v8hHkYC4RXc_dFwqb7dX2MlTf0V8lqj



Reviewing Matlab
----------------
The tutorial assumes that readers are familiar with the basics of Matlab. In particular, it will be useful to understand how to:

* Create variables
* Call functions,
* Index into arrays, and
* Write a ``for`` loop

If you are new to Matlab, you may want to review these topics as you read through the tutorial.

The official Matlab documentation includes a good starting guide: `Getting Started Guide`_

Python users might find this cheatsheet useful: `Python to Matlab Cheatsheet`_

And there are many other resources online.

.. _Getting Started Guide: https://www.mathworks.com/help/matlab/getting-started-with-matlab.html

.. _Python to Matlab Cheatsheet: https://www.mathworks.com/content/dam/mathworks/fact-sheet/matlab-for-python-users-cheat-sheet.pdf



.. toctree::
    :hidden:

    DA Primer           <da-primer>
    Tutorial Outline    <tutorial-outline>
    Introducing DASH    <dash/outline>
    Demos               <demos>
    gridfile            <gridfile/outline>
    stateVector         <stateVector/outline>
    PSM                 <PSM/outline>
    kalmanFilter        <kalmanFilter/outline>
    Next Steps          <next-steps>
