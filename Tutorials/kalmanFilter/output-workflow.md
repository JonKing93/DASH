---
layout: simple_layout
title: Output Workflow
---

# Regridding Output

It is often useful to reshape output state vector to spatial regrids. Recall that the [ensembleMetadata.regrid](..\ensembleMetadata\regrid) can be useful for this. For example, say I have a state vector that includes a temperature variable (named "Temp") and that I want to plot the updated temperature field from an assimilation. I could use:
```matlab
[T_updated, meta] = ensMeta.regrid(output.Amean, 'Temp');
```
to return the spatially gridded, updated temperature field and its metadata.



# Output Summary

The following table summarizes the output options for a kalmanFilter

Description | Command | Output Field | Dimensions | Required Updates
----------- | ------- | ----------- | ---------- | ----------------
Calibration Ratio | N/A | calibRatio | Proxies x Time | None
Ensemble Mean | mean | Amean | State Vector x Time | Mean
Ensemble Variance | variance | Avar | State vector x Time | Deviations
Ensemble Percentiles | percentiles | Aperc | State vector x Percentiles x Time | Mean and Deviations
Ensemble Deviations | deviations | Adev | State vector x Ensemble members x Time | Deviations
Posterior Index | index | index_<name> | Ensemble members x Time | Mean and Deviations


We have now seen all the various output options for a Kalman Filter analysis. In the next sections, we will shift focus and examine how to design evolving priors, and how to adjust model covariance estimates.

[Previous](index)---[Next](evolve)
