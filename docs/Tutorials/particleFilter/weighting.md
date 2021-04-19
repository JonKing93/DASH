---
sections:
  - Weighting
  - Bayesian weights
  - Best N particles
---

<script async src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>

# Weighting scheme

You can use the "particleFilter.weighting" command to select a weighting scheme to use for the particle filter weights. Here, the syntax is:
```matlab
pf = pf.weighting( name, parameters )
```
where "name" is the name of the weighting scheme, and "parameters" are any additional parameters required to implement the weights. The particleFilter class currently supports two weighting schemes:
1. Bayesian weights, and
2. A "best N" particles scheme

### Bayesian weights

The Bayesian weighting scheme computes particle weights using:

$$SSE_i = -\frac{1}{2}(Y-Ye_i)^T R^{-1}(Y-Ye_i)$$

$$w_i = \frac{ exp[SSE_i] }{\sum_{i=1}^N exp[SSE_i]}$$

effectively using Bayes' theorem to weight each particle. This is the default weighting scheme, and is used in the particle filter if the weighting scheme is unspecified. You can explicitly select this scheme using the following:
```matlab
pf = pf.weighting('bayes');
```

### Best N Particles

The "Best N" weighting scheme determines the N particles that are most similar to the observations and then applies an equal weighting to those N particles. Weights for the remaining particles are set to zero. You can select this scheme using:
```matlab
pf = pf.weighting('best', N);
```
where N is a scalar positive integer indicating the number of best particles to use. For example:
```matlab
N = 4;
pf = pf.weighting('best', N);
```
will create the weighting using the best 4 particles. In each time step, four particles will have a weight of 1/4, and the remaining particles will have a weight of 0.
