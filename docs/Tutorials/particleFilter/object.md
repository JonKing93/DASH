
# Overview

The Particle Filter class allows you to create and modify particleFilter objects, which can be used to run particle filter analyses. When implementing a particle filter, the general workflow is to

1. Initialize a new particleFilter object,
2. Provide essential inputs (observations, uncertainties and observation estimates),
3. Optionally select a particle weighting scheme
4. Optionally provide a prior to update, and then
5. Run the filter

We will cover each of these steps in detail through this tutorial.

### particleFilter Objects

A particle filter analysis begins by initializing a new particleFilter object, which will store settings and inputs for the analysis. You can create a particleFilter object using the "particleFilter" command:

```matlab
pf = particleFilter;
```

Here, pf is a new particleFilter object. Throughout this tutorial, I will use "pf" to refer to a particleFilter object, however feel free to use a different convention in your own code.

#### Optionally name a particle filter

You can optionally name a particle filter object by providing a string as the first input to the particleFilter command. For example:
```matlab
name = 'The name of my filter';
pf = particleFilter(name);
```

This can be useful to help distinguish between partifleFilter objects when running many different analyses. You can access this name later using the "name" command:
```matlab
pf.name
```

You can also rename a filter at any time by using the "rename" command and providing a new name:
```matlab
newName = 'A different name';
pf = pf.rename(newName);
```

At this point, "pf" is an empty analysis; it does not yet have enough information to run a particle filter. In the next section, we will see how to provide the essential inputs required to run a particle filter analysis.
