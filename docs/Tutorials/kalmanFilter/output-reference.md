# Output Quick Reference

The following table summarizes the output options for a kalmanFilter

Description | Command | Output Field | Dimensions | Required Updates
----------- | ------- | ----------- | ---------- | ----------------
Calibration Ratio | N/A | calibRatio | Proxies x Time | None
Ensemble Mean | mean | Amean | State Vector x Time | Mean
Ensemble Variance | variance | Avar | State vector x Time | Deviations
Ensemble Percentiles | percentiles | Aperc | State vector x Percentiles x Time | Mean and Deviations
Ensemble Deviations | deviations | Adev | State vector x Ensemble members x Time | Deviations
Posterior Index | index | index_&lt;name&gt; | Ensemble members x Time | Mean and Deviations
