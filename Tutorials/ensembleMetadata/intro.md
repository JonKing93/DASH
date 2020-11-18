---
layout: simple_layout
title: ensembleMetadata
---

# Where we've been. Where we're going

In previous tutorials, we saw how to use the gridfile, stateVector, and ensemble modules to facilitate the creation of state vector ensembles. These state vector ensembles are a core part of paleoclimate data assimilation. For example, they can be used:
1. As an assimilation prior
2. To estimate climate system covariance, and
3. As inputs to proxy system models to generate proxy estimates.

For each of these cases, it is often useful to extract metadata for elements down the state vector and across the ensemble. You can use the ensembleMetadata class to facilitate extracting such metadata. Several examples are provided to illustrate common use cases.

#### Example 1: Covariance Localization

When using a state vector ensemble to estimate climate system covariance, you may want to use covariance localization. To implement a covariance localization scheme, you will need to know the latitude-longitude coordinate of each element down the state vector. You can use the ensembleMetadata module to obtain the latitude-longitude metadata for each state vector element.

#### Example 2: Proxy System Models

A common task in paleoclimate data assimilation is applying a proxy system model (PSM) to a state vector ensemble in order to generate proxy estimates for the ensemble. When doing so, you want to ensure that the PSM receives the correct climate variables as inputs. PSMs are typically for a specific proxy site, so you will often want find the climate points closest to the proxy site to use as PSM inputs. Finally, some proxy sites have a known seasonality, so you may want to use time steps from a particular season as the inputs to a PSM. You can use the ensembleMetadata module to find state vector elements that correspond to specific variables, spatial coordinates, and time steps.

#### Example 3: Evolving Priors

In some cases, you may want to use different subsets of a state vector ensemble as priors for different assimilated time steps. For example, you may want to use a different prior in different months, or different priors for pre-industrial and post-industrial periods. To design these evolving priors, you will need to be able to find ensemble members with specific characteristics within the state vector ensemble. You can use the ensembleMetadata module to obtain metadata for different ensemble members, which can then be used to select different subsets of the full ensemble.

In the next few sections, we will see how to implement these tasks.

[Previous](welcome)---[Next](meta-object)



 To do so, you will need to sort and select different ensemble members
