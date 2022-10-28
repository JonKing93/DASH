Next Steps
==========
Thanks for attending the Paleo DA Hackathon!

After the workshop (or if you finish early), try experimenting with other tools in the DASH toolbox. Some possible ideas include:

* Compare the time to update the ensemble mean vs. mean and deviations
* Run the demos with a different localization radius
* Run the demos with inflation instead of localization
* LGM Demo: Use ``PSM.estimate`` to generate validation proxies from the updated ensemble
* LGM Demo: Incorporate proxy seasonality into the PSM inputs (Hint: See the ``checkSeasonality`` command from the BaySPLINE code)
* NTREND Demo: Compute a temperature index from the updated field and compare it with the assimilated index
* NTREND Demo: Withhold some proxies from the assimilation
* Use the ``ensemble.useMembers`` command to rerun an assimilation with different ensemble members
* Create an evolving prior
* Run a particle filter or optimal sensor
* Build a ``.grid`` data catalogue
* Make a framework for online assimilation
* Or anything else that raises your interest

Also keep an eye out for the official v4 release next week - the release will include an expanded version of this workshop that covers all the classes in DASH.

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

Finally, we welcome contributions and feedback. If you have any questions, find a command confusing, or have ideas for new features - don't hesitate to reach out!

Thanks again for attending!
