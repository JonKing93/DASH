---
sections:
  - Overview
  - optimalSensor objects
  - Name an optimal sensor
---
# Overview
The optimalSensor class allows you to rank sampling sites by their ability to reduce uncertainty for a reconstruction target. The method uses an ensemble of climate states to compute a probability distribution for a reconstruction target. A modified Kalman Filter then ranks potential sampling sites by their ability to reduce the spread of this distribution. For more details, please see [Comboul et al., 2015](https://doi.org/10.1175/JCLI-D-14-00802.1).

When using the optimalSensor module, general workflow is to:

1. Initialize a new optimalSensor object
2. Provide a prior ensemble
3. Specify a reconstruction target,
4. Specify observations estimates and uncertainties for potential sampling sites, and
5. Run the optimal sensor experiment

We will cover each of these steps in detail through this tutorial.

### optimalSensor objects
An optimal sensor analysis begins by initializing a new optimalSensor object, which stores settings and inputs for the experiment. You can create an optimalSensor object using the "optimalSensor" command:
```matlab
os = optimalSensor;
```

Here, os is a new optimalSensor object. Throughout this tutorial, I will use "os" to refer to an optimalSensor object, however feel free to use a different convention in your own code.

### Name an optimal sensor

You can optionally name an optimal sensor object by providing a string as the first input to the optimalSensor command. For example:
```matlab
name = 'The name of my experiment';
os = optimalSensor(name);
```

You can rename an optimalSensor at any time by using the "rename" command and providing a new name:
```matlab
newName = 'A different name';
os = os.rename(newName);
```

At this point, "os" is an empty experiment; it does not yet have enough information to run an optimal sensor experiment. In the next sections, we will see how to provide the essential inputs required to run an optimal sensor analysis.
