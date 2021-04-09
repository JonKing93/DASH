<script async src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>


# Linear PSMs

You can use the "linearPSM" class to create PSMs that implement a linear relationship of the form:

$$
Y = a_1X_1 + a_2X_2 + ... + a_nX_n + b
$$


### Create a linear PSM
You can create a linearPSM object using the following syntax:
```matlab
psmObject = linearPSM(rows, slopes, intercept)
```

Here, "rows" is the usual vector of state vector rows required to run the PSM. The first listed row points to the values for $$X_1$$, the second row to $$X_2$$, and the Nth row to $$X_n$$. The "slopes" input is a numeric vector that lists the coefficients $$a_1, a_2, ..., a_n$$. Finally, "intercept" is the constant $$b$$ in the linear relationship.

For example, let's say I want a PSM that implements a linear relationship of temperature ("T") and precipitation ("P") for a proxy site at [60N, 120E]. The coefficient for the temperature variable is 0.5, and the coefficient for the precipitation variable is 2. The relationship has an intercept of 17. Then I could do:
```matlab
Trow = ensMeta.closestLatLon([60, 120], "T");
Prow = ensMeta.closestLatLon([60, 120], "P");
rows = [Trow, Prow];

slopes = [0.5, 2];
intercept = 17;

myPSM = linearPSM(rows, slopes, intercept)
```

Note that the slopes must be provided in the same order as state vector rows. So if I changed the "rows" input to:
```matlab
rows = [Prow, Trow];
```
then I would also need to change the slopes to:
```matlab
slopes = [2, 0.5];
```

### Use the same slope for all variables

You can use the same slope for all variables $$X_1, X_2, ..., X_n$$ by using a scalar for the "slopes" input. For example, let's say I want a PSM that calculates an annual mean over a monthly temperature variable ("T_monthly") for a proxy site at [60W, 120E]. Each monthly variable will have the same coefficient of (1/12), so I could do:
```matlab
rows = ensMeta.closestLatLon([60 120], "T_monthly");
slope = 1/12;
intercept = 0;
myPSM = linearPSM(rows, slope, intercept);
```

### Default intercept of 0

If you do not provide an intercept, then it will default to zero. Continuing the previous example of a monthly temperature mean, I could equivalently use:
```matlab
slope = 1/12;
myPSM = linearPSM(rows, slopes);
```

### linearPSM.run

To use the "run" command, use the following syntax:
```matlab
Ye = linearPSM.run(Xpsm, slopes, intercept);
```

Here, Xpsm is a matrix with the $$X$$ variables for the PSM. Each row holds the values for a particular $$X_1, X_2, ..., X_n$$. The slopes and intercept inputs are the same as for PSM creation. The order of the slopes should match the order of rows in Xpsm.


This is currently the only PSM provided with DASH. However, more PSMs are in the works.
