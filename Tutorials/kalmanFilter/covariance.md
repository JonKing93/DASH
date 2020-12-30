---
layout: simple_layout
title: Covariance Adjustments
---

# Covariance Adjustments

By default, DASH estimates climate system covariance using the covariance of the prior ensemble with the proxy estimates. However, prior ensembles are typically constructed from climate model output, which are imperfect representations of the Earth system. Consequently, the Kalman Filter covariance estimates can exhibit biases caused by the underlying climate model. Separately, sampling errors in small ensembles can also bias Kalman Filter covariance estimates.

Kalman Filter objects can implement several techniques to help mitigate these covariance biases. These include:
* [Covariance Localization](localize)
* [Blending](blend) covariance estimates with estimates from a larger ensemble
* [Covariance Inflation](misc-cov#covariance-inflation), and
* [Directly setting a covariance matrix](misc-cov#set-covariance-directly).

The remainder of the tutorial will examine these techniques in detail.

[Previous](evolve)---[Next](localize)
