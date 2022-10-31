ensemble
========

Ensemble Files
--------------
At the end of the last coding session, we discussed how the ``stateVector.build`` command can save a state vector ensemble to file, rather than returning the ensemble directly as an array. In general, we recommend saving ensembles to file because it affords several advantages:

First, ensemble files allow DASH to conserve computer memory when conducting data assimilation. Most commands **do not** require using all the data within an ensemble. Instead, they typically require a small subset of ensemble data - ranging from a few variables (as reconstruction targets), to a few rows (used to run a forward model). Using ensemble files allows the ``DASH`` toolbox to optimize its use of computer memory and only load data that is strictly necessary for an operation. This can significantly increase the speed of assimilation algorithms later on.

Other advantages of ensemble files pertain to using an ensemble over multiple coding session. Some ensembles can take a while to build (particularly ensembles with large state vectors). Saving to file allows you to reuse the same ensemble without waiting for it to rebuild. Furthermore, if you select ensemble members randomly, you may select different ensemble members when you rebuild the ensemble. Saving to file ensures that you use the same ensemble members over multiple coding sessions.


``ensemble`` class
------------------
The ``ensemble`` class allows you to manipulate and interact with state vector ensembles saved in these ensemble files. The class implements ensemble objects - each object is associated with a particular ensemble file, and allows you to manipulate and load the data in that file. The class also helps several common routines for data assimilation, such as designing evolving (time-dependent) ensembles. We'll use the remainder of this page to examine some key features of the ``ensemble`` class.


Features
--------

Placeholder for large arrays
++++++++++++++++++++++++++++
You can use ensemble objects in lieu of data arrays within the ``DASH`` toolbox. A number of commands in ``DASH`` require an ensemble as input, but very large ensembles can be difficult to fit in a computer's active memory. To circumvent this problem, you can use ensemble objects to input ensembles for ``DASH`` commands. Many ``DASH`` commands include memory optimizations for large ensembles, and they can use the ensemble object to load necessary data without overwhelming your computer. The ensemble object itself only contains a small amount of metadata about the saved array, so should easily fit in active memory.



Load Saved Ensemble
+++++++++++++++++++
The ``ensemble`` class implements a ``load`` command, which returns the ensemble saved in a file. The ensemble is returned directly as a data array, and if necessary, you can manipulate this data array in the Matlab workspace prior to assimilation. You can also modify the output of the ``load`` command using the commands described below.



Select Variables and Members
++++++++++++++++++++++++++++
Sometimes, you may only need a few of the variables saved in an ensemble file. For example, when running an assimilation algorithm, you only need to update the variables that represent reconstruction targets. By using the ``useVariables`` command, you can modify an ensemble object so that it only represents a subset of variables saved in the file. If you then use the ``load`` command, the output will only include the requested variables.

Similarly, you may want an ensemble to use a specific set of ensemble members. For example, if you are implementing a Monte Carlo procedure and rerunning an assimilation using different sets of ensemble members. You can use the ``useMembers`` command to select specific ensemble members saved in the file. If you then use the ``load`` command, the output will only include the requested variables.



Evolving Ensembles
++++++++++++++++++
In some cases, you may want to design an evolving ensemble. This is typically the case when you want to use different prior ensembles for different assimilation time steps. You can use the ``evolving`` command to implement an evolving ensemble. This command allows you to select different sets of saved ensemble members. Each set of ensemble members is used to build a particular ensemble within an evolving set.

In some cases, you may want to build an evolving ensemble from data saved in different ensemble files. If this is the case, you can build an ensemble by concatenating individual ensemble objects into an vector. Each element of the vector is a particular ensemble in the evolving set. Finally, you can also build evolving ensembles directly from a data array. See the documentation in ``dash.doc('kalmanFilter')`` and ``dash.doc('kalmanFilter.prior')`` for more details on these two cases.


Regrid Variable
+++++++++++++++
In some cases, you might want to load a state vector variable on its original data grid, rather than as a state vector. You can use the ``loadGrid`` command to implement this behavior. This command is best used when you want to double check an ensemble and ensure that everything looks correct. In most other cases, we instead recommend the ``ensembleMetadata.regrid`` command, which provides a more powerful interface.
