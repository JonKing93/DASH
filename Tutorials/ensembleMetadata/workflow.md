---
layout: simple_layout
title: Automatic Workflow
---

# Automated Workflow

The "variable" and "findRows" methods are sufficient to extract metadata for any element or ensemble member in a state vector ensemble. However, there are certain metadata tasks that recur in many different assimilations. One of the most common tasks involves finding climate variable grid points closest to a proxy site in order to run a proxy system model. Another common task involves obtaining latitude-longitude coordinates for each state vector element in order to implement covariance localization. Because these tasks are so common, ensembleMetadata provides several methods to help automate this workflow. These workflow methods are the focus of the next few sections.

[Previous](variable)---[Next](dimension)
