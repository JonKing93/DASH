Next Steps
==========
Thanks for reading out the tutorial!

After you finish, try experimenting with other tools in the DASH toolbox. Some possible ideas include:

* Run the demos with a different localization radius
* Run the demos with inflation instead of localization
* Compare the time to update the ensemble mean vs. mean and deviations
* LGM Demo: Use ``PSM.estimate`` to generate validation proxies from the updated ensemble
* LGM Demo: Incorporate proxy seasonality into the PSM inputs (Hint: See the ``checkSeasonality`` command from the BaySPLINE code)
* NTREND Demo: Compute a temperature index from the updated field and compare it with the assimilated index
* NTREND Demo: Withhold some proxies from the assimilation
* Use the ``ensemble.useMembers`` command to rerun an assimilation with different ensemble members
* Create an evolving prior
* Make a framework for online assimilation
* Or anything else that raises your interest

----

You can also read in depth about the commands in the DASH toolbox in the reference guide at::

    dash.doc

We recommend reading the documentation of the different classes, as they contain outlines for working with their commands. A suggested reading order:

* ``gridMetadata``
* ``gridfile``
* ``stateVector``
* ``ensemble``
* ``ensembleMetadata``
* ``PSM``
* ``kalmanFilter``
* ``particleFilter``
* ``optimalSensor``

----

Finally, we welcome contributions and feedback. If you have any questions, find a command confusing, or have ideas for new features - don't hesitate to reach out! You can contact the developers by sending an email to DASH.toolbox@gmail.com, or by submitting a pull request to the `DASH repository <https://github.com/JonKing93/DASH>`_.
