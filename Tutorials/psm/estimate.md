---
layout: simple_layout
title: Estimate Proxies
---

# Estimate Proxies

One of the benefits of PSM objects is that they all share a common interface. This interface allows you to estimate proxies for *any* PSM using the same command: "PSM.estimate". To call this command, use the following syntax:
```matlab
Y = PSM.estimate(X, psmObject)
```
Here, X is a state vector ensemble, psmObject is a specific PSM object, and "Y" is the proxy system estimates. For example, let's say I have a state vector ensemble with 1000 ensemble members and I want to estimate proxy observations using the linear PSM from the previous example. Then I could do
```matlab
X = ens.load;
myPSM = linearPSM(rows, slope, intercept);
Y = PSM.estimate(X, myPSM);
```

Here, Y would be a row vector with 1000 elements. Each element is the proxy estimate for the corresponding ensemble member.

### Multiple proxy sites

In most cases, you will want to estimate proxy values for multiple proxy sites, which will require multiple PSM objects. To call "PSM.estimate" for multiple PSM objects, collect the PSMs in a cell vector. For example, let's say I now want to estimate proxy observations using the linear PSM and the VS-Lite PSM from the previous examples. I will estimate proxy values for the same 1000 member ensemble (X). Then I could do:
```matlab
myPSMs = cell(2,1);
myPSMs{1} = linearPSM(rows1, slope, intercept);
myPSMs{2} = vslitePSM(rows2, latitude, T_threshold, P_threshold);

X = ens.load;

Y = PSM.estimate(X, myPSMs);
```
Here, Y will have a size of (2 x 1000). The first row will hold the estimates for the proxy site using the linear PSM, and the second row will hold the estimates for proxy site using the VS-Lite PSM.

### Estimate proxy uncertainty (R)

Some PSMs can estimate the proxy measurement uncertainty for a site. (In the Kalman Filter tutorial, we refer to this as R). Use the second output to obtain any estimated R values:
```matlab
[Y, R] = PSM.estimate(X, psmObjects);
```

Continuing the example:
```matlab
[Y, R] = PSM.estimate(X, myPSMs);
```
R will be a vector with two elements. The first element will hold the R estimate for the proxy site using the linear PSM, and the second element will hold the R estimate for the proxy site using the VS-Lite PSM.

It's important to note that not all PSMs can estimate R values. If a PSM cannot estimate R values, the R value for that proxy site will be NaN. Continuing the example, linear PSMs do not have the ability to estimate R vaues, so the first element of R will be NaN.


### Estimate proxies for very large ensembles

In some cases, you may have a state vector ensemble that is too large to fit into active memory. Typically, these very large ensembles are saved in a ".ens" file. You can estimate proxies for these state vector ensembles by providing an ensemble object as the first input to "PSM.estimate". For example, if I want to apply the linear PSM from the previous examples to a very large ensemble, I could do:

```matlab
ens = ensemble('my-very-large-ensemble.ens');
rows = ens.metadata.closestLatLon([60 120], "Temperature");

myPSM = linearPSM(rows, slope, intercept);
Y = PSM.estimate(ens, myPSM);
```

We have now seen how to estimate proxy values using PSM objects. In the next sections of this tutorial, we will focus on specific PSMs and the input arguments required to create them.

[Previous](object)---[Next](linear)
