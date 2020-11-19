---
layout: simple_layout
title: ensembleMetadata
---

# Where we've been. Where we're going

In previous tutorials, we saw how to use the gridfile, stateVector, and ensemble modules to facilitate the creation of state vector ensembles. These state vector ensembles are a core part of paleoclimate data assimilation. For example, they can be used:
1. As an assimilation prior
2. To estimate climate system covariance, and
3. As inputs to proxy system models to generate proxy estimates.

In each of these cases, it is useful to extract the metadata of elements down the state vector or across the ensemble. You can use the ensembleMetadata class to facilitate extracting such metadata. Several examples are provided to illustrate common use cases.

#### Example 1: Covariance Localization

When using a state vector ensemble to estimate climate system covariance, you may want to use covariance localization. To implement a covariance localization scheme, you will need to know the latitude-longitude coordinate of each element down the state vector. You can use the ensembleMetadata module to obtain the latitude-longitude metadata for each state vector element.

#### Example 2: Proxy System Models

A common task in paleoclimate data assimilation is applying a proxy system model (PSM) to a state vector ensemble in order to generate proxy estimates. When doing so, you want to ensure that the PSM receives the correct climate variables as inputs. PSMs are typically for a specific proxy site, so you will often want find the points of the climate variable closest to the proxy site to use as PSM inputs. Finally, some proxy sites have a known seasonality, so you may want to use time steps from a specific season as the inputs to a PSM. You can use the ensembleMetadata module to find state vector elements that correspond to specific variables, spatial coordinates, and time steps.

#### Example 3: Regridding state vectors
In most analyses, you will eventually want to reshape state vector variables back into gridded climate variables. For example, after data assimilation, you may want to convert a variable in a posterior state vector ensemble back into a gridded form so that you can plot it in a figure. Regridding a variable in this way requires knowledge of the metadata associated with the variable's gridded dimensions. Consequently, you can use the ensembleMetadata class to perform this transformation.

#### Example 4: Evolving Priors

In some cases, you may want to use different subsets of a state vector ensemble as priors for different assimilated time steps. For example, you may want to use a different prior in different months, or different priors for pre-industrial and post-industrial periods. To design these evolving priors, you will need to be able to find ensemble members with specific characteristics within the state vector ensemble. You can use the ensembleMetadata module to obtain metadata for different ensemble members, which can then be used to select different subsets of the full ensemble.

# Tutorial Overview
In this tutorial, we will review some of the most commonly used features of ensembleMetadata. Specifically, we will examine how to return:
1. The names of variables in the state vector and their sizes,
2. Regridded state vector variables,
3. Metadata at any point in a state vector ensemble, and
4. Latitude-Longitude coordinates down the state vector to implement covariance localization,
5. Rows associated with climate variable points closest to a proxy sites, and
6. Sanity checks for metadata.

These topics highlight the most common uses of ensembleMetadata, but the class implements other features as well. In particular, if you are interested in concatenating ensembles, removing variables or ensemble members, or exercising greater control over metadata queries, check out the [Advanced Topics page](advanced).

[Previous](welcome)---[Next](meta-object)
