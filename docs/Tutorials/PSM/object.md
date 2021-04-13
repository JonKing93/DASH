---
sections:
  - PSM overview
  - PSM objects
  - Initialize a new PSM
  - The rows input
  - Example 1
  - Example 2
  - Name a PSM
---

### PSM objects
Once you have downloaded any external PSM code, you can begin designing a PSM for each proxy site. You can design the PSM for each site using PSM objects. Each PSM object implements a particular type of PSM with site-specific settings. PSMs can range in complexity from a simple linear relationship, to more sophisticated process-based models, and may require different climate variables to run. PSM objects allow you to implement disparate forward models for different proxy sites in a modular and automated manner.

### Initialize a new PSM
The exact command used to create a PSM object will vary with the PSM itself. However, PSM creation always uses the same general syntax:
```matlab
psmObject = psmName(rows, parameter1, parameter2, .., parameterN)
```

* Here, psmName is the name of a specific PSM class. For example, use the "linearPSM" class to create a PSM that implements a general linear relationship. Alternatively, use the "vslitePSM" class to create a PSM that implements VS-Lite. You can find a list of PSM classes [here].

* The "rows" argument indicates which state vector elements are required to run a PSM. This way, the PSM for each proxy site knows what data to use to run. The [ensembleMetadata class](..\ensembleMetadata\welcome) is useful for determining the rows; in particular, the [ensembleMetadata.closestLatLon command](..\ensembleMetadata\closest).

* parameters 1 through N are any additional inputs required to run the PSM, which will vary with the specific PSM being created. You can read about these inputs in detail on the [pages for individual PSMs](advanced).

* psmObject is the new PSM object for a specific proxy site.

### The "rows" input

The rows input indicates which state vector rows hold the data needed to run the PSM; it is an array with up to three dimensions. If rows has a single column, then the same state vector rows will be used for all ensemble members. For example:
```matlab
rows = [2
        5];
```
will use the second and fifth state vector elements to run the PSM for each ensemble member.

However, rows can instead have one column per ensemble member. In this case, each column indicates the state vector elements to use for a particular ensemble member. This can be useful if a prior contains NaNs in some ensemble members, but not others. As an example, say I have a state vector ensemble with three ensemble members. Then you could do:
```matlab
rows = [2 2 3;
        5 6 5];
```
to use state vector elements 2 and 5 to run the PSMs for the first ensemble member, elements 2 and 6 for the second member, and 3 and 5 for the third.

If "rows" has a single element along the third dimension, then the same state vector elements will be used to run the PSMs for all priors. However, if you are using transient offline priors for data assimilation, you can specify different state vector elements for different priors using the third dimension of "rows". For example, if I have two priors, as per:
```matlab
ens1 = ensemble('my-ensemble-1.ens');
X1 = ens1.load;

ens2 = ensemble('my-ensemble-2.ens');
X2 = ens2.load;

X = cat(3, X1, X2);
```

then I can do:

```matlab
rows1 = [2;5];
rows2 = [3;6];
rows = cat(3, rows1, rows2);
```
to use state vector elements 2 and 5 to run the PSMs for the first prior, and elements 3 and 6 to run the PSMs for the second prior.

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
