---
layout: simple_layout
title: Output Workflow
---

# Regridding Output

It is often useful to reshape output state vector to spatial regrids. Recall that [ensembleMetadata.regrid](..\ensembleMetadata\regrid) can help facilitate this. For example, say I have a state vector that includes a temperature variable (named "T") and that I want to map the updated temperature field from an assimilation. I could use:
```matlab
[T_updated, meta] = ensMeta.regrid(output.Amean, 'T');
```
to convert the updated ensemble mean into a gridded field with associated metadata. Similarly:
```matlab
[T_percentiles, meta] = ensMeta.regrid(output.Aperc, 'T');
```
could be used to convert the percentiles of the posterior ensemble to a gridded field with metadata.


# Output Summary

The following table summarizes the output options for a kalmanFilter

Description | Command | Output Field | Dimensions | Required Updates
----------- | ------- | ----------- | ---------- | ----------------
Calibration Ratio | N/A | calibRatio | Proxies x Time | None
Ensemble Mean | mean | Amean | State Vector x Time | Mean
Ensemble Variance | variance | Avar | State vector x Time | Deviations
Ensemble Percentiles | percentiles | Aperc | State vector x Percentiles x Time | Mean and Deviations
Ensemble Deviations | deviations | Adev | State vector x Ensemble members x Time | Deviations
Posterior Index | index | index_&lt;name> | Ensemble members x Time | Mean and Deviations


We have now seen all the various output options for a Kalman Filter analysis. In the next sections, we will shift focus and examine how to design evolving priors, and how to adjust model covariance estimates.

[Previous](indices)---[Next](evolve)
