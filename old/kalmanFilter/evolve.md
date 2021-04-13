# Evolving Priors

We have previously seen how to use the "prior" command to provide a prior for a Kalman Filter analysis:
```matlab
kf = kf.prior(X);
```

In the previous examples, we used a static prior, and X had dimensions (State Vector x Ensemble Members). However, you can specify an evolving prior by organizing multiple priors down the third dimension. In this case, X will have dimensions (State Vector x Ensemble Members x Priors).

### Use a unique prior for each time step

To use a unique prior for each time step, organize the priors down the third dimension of X in the order of time steps. For example, say I have proxy observations in 3 time steps. Then I could do:
```matlab
prior1 = ensemble('prior-1.ens');
prior2 = ensemble('prior-2.ens');
prior3 = ensemble('prior-3.ens');

X = cat(3, ens1.load, ens2.load, ens3.load);
kf = kf.prior(X);
```
to use a unique prior in each time step.

### Select priors for specific time steps

Alternatively, you can use a second input to specify which prior to use for each time step. Here, the syntax is:
```matlab
kf = kf.prior(X, whichPrior);
```
Here, "whichPrior" is a vector with one element per assimilated time step. Each element is the index of the prior to use for the time step.

##### Example 1: Change priors at a specific time step
For example, say I have proxy observations in 1150 time steps. The first 1000 observations are from 851 to 1850 CE, and the last 150 observations are from 1851 to 2000 CE. I have two priors: one for the pre-industrial (851-1850) era, and one for the post-industrial (1851-2000) era. Thus, I want to use the pre-industrial prior for the first 1000 time steps and use the post-industrial prior for the last 150 time steps. Then I could do:
```matlab
prior1 = ensemble('my-preindustrial-prior.ens');
prior2 = ensemble('my-postindustrial-prior.ens');

X = cat(3, prior1.load, prior2.load);
whichPrior = [1*ones(1000,1); 2*ones(150,1)];

kf = kf.prior(X, whichPrior)
```
This indicates that the Kalman Filter should use the first prior in X for the first 1000 time steps, and the second prior in X for the last 150 time steps.

##### Example 2: Cyclic Seasonal Priors
Alternatively, you might want to use cyclical evolving priors for different seasons or months. For example, say you have seasonal observations (spring, summer, autumn, winter) over 250 years for a total of 1000 assimilated time steps. You have a different prior for each season: one for spring, summer, autumn, and winter and want to change the prior cyclically with the season. Then you could do:
```matlab
spring = ensemble('spring-prior.ens');
summer = ensemble('summer-prior.ens');
autumn = ensemble('autumn-prior.ens');
winter = ensemble('winter-prior.ens');

X = cat(3, spring.load, summer.load, autumn.load, winter.load);
whichPrior = repmat(1:4, [1, 250]);

kf = kf.prior(X, whichPrior);
```
This specifies that the Kalman Filter should cyclically alternate over the four priors over the reconstruction.


### Specify estimates for evolving priors

When you provide multiple priors to a kalmanFilter object, you must also specify proxy estimates for each prior. You can use the "estimates" command with the normal syntax to estimate proxy values for multiple priors:
```matlab
kf = kf.estimates(Ye)
```
However, Ye must have three dimensions (State Vector x Ensemble Members x Priors) and the estimates for the different priors should be organized down the third dimension.

The "PSM.estimate" command can facilitate estimates for multiple priors using the normal syntax. Building off the previous example, say you have a vector of PSM objects (named myPSMs). Then you could do:
```matlab
X = cat(3, spring.load, summer.load, autumn.load, winter.load);
Ye = PSM.estimate(X, myPSMs);
kf = kf.estimates(Ye);
```
Here, Ye will have three dimensions (Proxies x Ensemble Members x Priors), and the length of the third dimension will be 4 (one element for each seasonal prior).
