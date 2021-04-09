# PSM Overview
The PSM class is most commonly used to estimate proxy observations for a model ensemble. There are two key steps in this process:
1. Designing PSMs for individual proxy sites, and
2. Using the PSM.estimate command to estimate values for all the different proxy sites.

### PSM objects
You can design PSMs for different proxy sites using PSM objects. Each PSM object implements a particular type of PSM with site-specific settings. PSMs can range in complexity from a simple linear relationship, to more sophisticated process-based models. The PSMs in DASH include:
* multiple linear relationships
* VS-Lite
* BAYMAG / BAYSPAR / BAYSPLINE, and
* interfaces with PRySM

PSM objects allow you to use these different types of PSMs, and different site settings, in a modular and automated manner.

The exact command used to create a PSM object will vary with the PSM itself. However, PSM creation always uses the same general syntax:
```matlab
psmObject = psmName(rows, otherInput1, otherInput2, .., otherInputN)
```

* Here, psmName is the name of a specific PSM class. For example, use the "linearPSM" class to create a PSM that implements a linear relationship. Alternatively, use the "vslitePSM" class to create a PSM that implements VS-Lite.

* The "rows" argument indicates which state vector elements are required to run a PSM. This way, the PSM for each proxy site knows what data to use to run. The [ensembleMetadata class](..\ensembleMetadata\welcome) is useful for determining the rows; in particular, the [ensembleMetadata.closestLatLon command](..\ensembleMetadata\closest).

* otherInput 1 through N are any additional inputs required to run the PSM, which will vary with the specific PSM being created. We will examine these inputs in detail for specific PSMs later in the tutorial.

* psmObject is the new PSM object for a specific proxy site.


#### Example 1
Let's say I want to use the "linearPSM" class to create a linear, temperature PSM for a site at [60N, 120E]. In my state vector ensemble, the temperature variable is named "Temperature". Then I could do:
```matlab
rows = ensMeta.closestLatLon([60 120], "Temperature");
```
to find the state vector element for the temperature variable that is closest to the site.

In addition to state vector rows, linear PSMs require a slope and an intercept to run. Let's say I want to use a slope of 0.5, and an intercept of 0. Then I can create a PSM object for the site using:
```matlab
rows = ensMeta.closestLatLon([60 120], "Temperature");
slope = 0.5;
intercept = 0;
myPSM = linearPSM(rows, slope, intercept);
```

#### Example 2
Let's say I want to use the "vslitePSM" class to apply VS-Lite to a site at [32N, 110W]. VS-Lite requires monthly temperature and precipitation variables to run; let's say these are named "T_monthly" and "P_monthly" in my state vector ensemble. VS-Lite also requires the latitude of the proxy site (32 N), temperature thresholds (let's say 0C and 40C for my site), and soil moisture thresholds (let's say 0 and 1). Then creating a PSM object for the site will look like:
```matlab
Trows = ensMeta.closestLatLon([32 -110], "T_monthly");
Prows = ensMeta.closestLatLon([32 -110], "P_monthly");
rows = [Trows; Prows];

latitude = 32;
T_thresholds = [0 40];
P_thresholds = [0 1];

myPSM = vslitePSM(rows, latitude, T_thresholds, P_thresholds);
```

### Name a PSM

You can use an optional, final argument to provide a name for a PSM. Here, the syntax is:
```matlab
psmObject = psmName(rows, input1, input2, .., inputN, name);
```
where "name" is a string scalar. Building off the previous examples, I could do

```matlab
rows = ensMeta.closestLatLon([60 120], "Temperature");
slope = 0.5;
intercept = 0;
name = 'My linear PSM';
myPSM = linearPSM(rows, slope, intercept, name);
```

to add a name to the linear PSM, or
```matlab
name = 'My VS-Lite PSM'
myPSM = vslitePSM(rows, latitude, T_thresholds, P_thresholds, name);
```

to name the VS-Lite PSM. You can access the name of a PSM using the "name" command. For example:
```matlab
myPSM.name
```
will return the name of the PSM. If you would like to change the name of a PSM, use the "rename" command and provide the new name as input. For example:
```matlab
newName = 'A new name for my PSM';
myPSM.rename(newName);
```

We have now seen some examples of how to create PSM objects. In the next section we will see how to use these objects to automatically estimate proxy observations from a state vector ensemble.
