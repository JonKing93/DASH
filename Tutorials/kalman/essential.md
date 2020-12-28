---
layout: simple_layout
title: Essentials
---

# Essential Inputs

There are four inputs that you must always provide in order to implement a Kalman Filter. These are
* Proxy records / Observations,
* Proxy / Observation Uncertainties,
* The Prior Ensemble, and
* Model estimates of proxies

### Proxy observations

You can specify proxy observations and their uncertainties using the "observations" command. Here, the syntax is:
```matlab
kf = kf.observations(Y, R)
```
Y is a matrix of observations; each row corresponds to a particular proxy site, and each column is a time step. R is the proxy uncertainty, and its form determines how proxy uncertainties are applied in the Kalman Filter. The following table specifies the possible forms of R

Type | Size | Application
---- | ---- | -----------
Scalar | 1 x 1 | Used as the uncertainty for all observations
Column Vector | Number of Proxy Sites x 1 | Each value is used as the uncertainty for the corresponding proxy in all time steps
Row Vector | 1 x Number of Time Steps | Each value is used as the uncertainty for all proxy observations in the corresponding time step
Matrix | Number of Proxy Sites x Number of Time Steps | Specifies a unique uncertainty for each observation







If R is a scalar, then it is used as the uncertainty for each proxy in each time step. R can also be a column vector with one element per proxy site; in this case, each element is used as the uncertainty for the corresponding proxy site in all time steps. Alternatively, R can be a row vector with one element per time step; here, each value is used as the uncertainty for all proxies in the corresponding time step. Finally, R can be







, and may be a scalar, vector or matrix. If R is a scalar, then it is used as the uncertainty for all proxies in all time s
* scalar: The same uncertainty is used for all proxies in all time steps
* column vector: Each p



: if R is a scalar, the Kalman Filter will use the same uncertainty for all proxies in all time steps
