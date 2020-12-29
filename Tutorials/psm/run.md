---
layout: simple_layout
title: Run PSM
---

# Run a PSM directly

In some cases, you may want to run a PSM directly, without needing to create a state vector ensemble or any PSM objects. You can do this using the "run" command using the syntax:
```matlab
Ye = psmName.run(input1, input2, .., inputN);
```

Here, psmName is the name of a specific type of PSM; for example, "linearPSM" or "vslitePSM". Input 1 through N are any inputs required to run the PSM, and Ye are the proxy estimates. For example, if I wanted to run a linear PSM without creating a PSM object, I could use:
```matlab
Ye = linearPSM.run(Xpsm, slopes, intercept);
```
where Xpsm are the data values needed to run the PSM.

Similarly, if I wanted to run VS-Lite directly, I could use
```matlab
Ye = vslitePSM.run(T, P, latitude, T_thresholds, P_thresholds);
```
where T and P are the temperature and precipitation values needed to run the PSM.

As we have seen, the inputs required to create a PSM object and to use the "run" command will vary with the specific PSM being used. In the remainder of the tutorial, we will focus on specific PSMs and the details of their inputs.

[Previous](estimate)---[Next](linear)







The inputs required to run a PSM will vary with the specific PSM being run, and these are examined in detail in the tutorial pages for specific PSMs.
