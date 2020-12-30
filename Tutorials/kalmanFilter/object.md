---
layout: simple_layout
title: New Kalman Filter
---

# Overview

The Kalman Filter class allows you to create and modify kalmanFilter objects, which can be used to run Kalman Filter analyses. When implementing a Kalman Filter, the general workflow is to

1. Initialize a new kalmanFilter object,
2. Provide essential inputs (such as a prior, proxy observations, uncertainties and estimates),
3. Make any covariance adjustments (such as localization or blending),
4. Choose output quantities, and then
5. Run the filter

We will cover each of these steps in detail through this tutorial.

### kalmanFilter Objects

A Kalman Filter analysis begins by initializing a new Kalman Filter object, which will store settings and inputs for the analysis. You can create a kalmanFilter object using the "kalmanFilter" command:

```matlab
kf = kalmanFilter;
```

Here, kf is a new kalmanFilter object. Throughout this tutorial, I will use "kf" to refer to a kalmanFilter object, however feel free to use a different convention in your own code.

#### Optionally name a Kalman Filter

You can optionally name a Kalman Filter object by providing a string as the first input to the kalmanFilter command. For example:
```matlab
name = 'The name of my filter';
kf = kalmanFilter(name);
```

This can be useful to help distinguish between kalmanFilter objects when running many different analyses. You can access this name later using the "name" command:
```matlab
kf.name
```

You can also rename a filter at any time by using the "rename" command and providing a new name:
```matlab
newName = 'A different name';
kf = kf.rename(newName);
```

At this point, "kf" is an empty analysis; it does not yet have enough information to run a Kalman Filter. In the next section, we will see how to provide the essential inputs required to run a Kalman Filter analysis.

[Previous](welcome)---[Next](essential)
