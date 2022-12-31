Installation
============

Prerequisites
-------------
DASH requires Matlab 2020b or higher, so you will need to install a recent version of Matlab before installing DASH. You can find the latest Matlab release here: `Latest Matlab release <https://www.mathworks.com/downloads/>`_.

(Note that you may need to create a MathWorks account to download Matlab).

.. tip::

    Matlab 2020b is the *minimum* requirement for DASH. In general, we recommend downloading the most recent Matlab release.


Installing DASH
---------------
There are several different ways to install DASH:

1. Using Github
2. Using MATLAB File Exchange, or
3. Via MATLAB's Add-On explorer

Use whichever method you find easiest.

Github
++++++

1. Navigate to the `latest DASH release`_.
2. Under the release assets, download the file: ``DASH-<version>.mltbx``
3. Open the downloaded file. This should automatically install the toolbox in your Matlab environment.


MATLAB File Exchange
++++++++++++++++++++

1. Navigate to the submission for the toolbox: `DASH on FileExchange <https://www.mathworks.com/matlabcentral/fileexchange/120453-dash>`_
2. Click on the ``Download`` button in the top right corner and select the ``Toolbox`` option. This should download a file with the name ``DASH-<version>.mltbx``.
3. Open the downloaded file. This should automatically install the DASH toolbox in your MATLAB environment.


MATLAB Add-On Explorer
++++++++++++++++++++++

1. Click on the ``Home`` tab in the MATLAB editor,
2. Click on the ``Add-Ons`` or ``Get Add-Ons`` button
3. Search for ``DASH`` and click on the entry for the toolbox (Its tagline is "A Matlab toolbox for paleoclimate data assimilation")
4. Click on the ``Add`` button in the top-right corner and follow the instructions.

.. _latest DASH release: https://github.com/JonKing93/DASH/releases/latest


Verify Installation
-------------------
You can verify your installation by entering ``dash.version`` in the MATLAB console. If the toolbox installed correctly, then this will display the current version of the toolbox in the console.



Updating DASH
-------------
You may want to update your DASH release when the toolbox is updated. To do so, follow the same steps as described for installing DASH. This should replace an old DASH version with the new release.
