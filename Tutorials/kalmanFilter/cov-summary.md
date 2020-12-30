---
layout: simple_layout
title: Covariance Summary
---

# Covariance Summary

There are many covariance options in DASH; the following section provides a summary and may be used as a quick reference.

Command | Description
------- | -----------
[localize](localize) | Localize covariance near proxy sites
[blend](blend) | Blend covariance with a static ensemble
[inflate](inflate) | Increase covariance by a multiplicative factor
[setCovariance](misc-cov#set-covariance-directly) | Directly specify a covariance matrix
[resetCovariance](misc-cov#reset-covariance-options) | Remove all covariance adjustments
[covarianceEstimate](misc-cov#get-covariance-of-an-assimilated-time-step) | Obtain the covariance estimate used in a particular time step of an assimilation
[dash.estimateCovariance](misc-cov#estimate-covariance) | Estimate covariance for an ensemble and associated proxy estimates

The order of covariance adjustments is:
1. Inflate prior covariance
2. Localize prior covariance
3. Blend prior covariance with static covariance

[Previous](misc-cov)---[All Tutorials](..\welcome)
