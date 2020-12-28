---
layout: simple_layout
title: Linear PSMs
---

# Linear PSMs

You can use the "linearPSM" class to create PSMs that implement a linear relationship of the form:

\\[ Y = a_1X_1 + a_2X_2 + ... + a_nX_n + b ]\\



### Create a linear PSM
You can create a linearPSM object using the following syntax:
```matlab
psmObject = linearPSM(rows, slopes, intercept)
```

Here, "rows" is the usual vector of state vector rows required to run the PSM. The first listed row points to the values for X_1, the second row is X_2, and the Nth row is X_n. The "slopes" input is a numeric vector that lists the coefficients a_1, a_2, ..., a_n. Finally, "intercept" is the constant "b" in the linear relationship.

For example, let's say I want a PSM that implements a linear relationship of temperature ("T") and precipitation ("P") for a proxy site at [60N, 120E]. The coefficient for the temperature variable is 0.5, and the coefficient for the precipitation variable is 2. The relationship has an intercept of 17. Then I could do:
```matlab
Trow = ensMeta.closestLatLon([60, 120], "T");
Prow = ensMeta.closestLatLon([60, 120], "P");
rows = [Trow, Prow];

slopes = [0.5, 2];
intercept = 17;

myPSM = linearPSM(rows, slopes, intercept)
```

### Use the same slope for all variables

You can use the same slope (a_1, a_2, ..., a_n) for all variables X_1, X_2, ..., X_n by using a scalar for the "slopes" input. For example, let's say I want a PSM that calculates an annual mean over a monthly temperature variable ("T_monthly") for a proxy site at [60W, 120E]. Each monthly variable will have the same coefficient of (1/12), so I could do:
```matlab
rows = ensMeta.closestLatLon([60 120], "T_monthly");
slope = 1/12;
intercept = 0;
myPSM = linearPSM(rows, slope, intercept);
```

### Optional: Name the PSM

Naming a PSM can be useful for tracking which PSMs correspond to which sites. These names are also provided in any error messages, which can be useful for debugging. To name a PSM, provide a string as the fourth input. For example:
```matlab
siteName = "My Site 1";
myPSM = linearPSM(rows, slope, intercept);
```

will identify my PSM as "My Site 1". You can access the name of a PSM using the "name" command. For example:
```matlab
myPSM.name
```
will return "My Site 1".

[Previous](estimate)---[Next](in-progress)
