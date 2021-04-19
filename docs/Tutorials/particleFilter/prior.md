---
sections:
  - Prior
  - Transient priors
  - Time-dependent priors
  - NaN values
---
# Prior

You can optionally provide a prior ensemble (X) to assimilate in a particle filter analysis. This prior will be used to compute a final climate state (sometime called the "analysis") for each assimilated time step. The analysis is computed as the weighted mean of the particles using the selected [particle filter weighting scheme](weighting).

Specify a prior using the "particleFilter.prior" command. Here, the syntax is:
```matlab
pf = pf.prior(X);
```
where X is a matrix with a state vector ensemble. Each row holds a particular state vector element, and each column is an ensemble member.

### Transient priors

If you would like to use transient offline priors, you can organize the priors along the third dimension of X. For example, if I have two saved priors, I could do:
```matlab
ens1 = ensemble('ensemble-1.ens');
ens2 = ensemble('ensemble-2.ens');

X = cat(3, ens1.load, ens2.load);
```
Note that transient priors must have the same number of state vector elements and ensemble members.

### Time-dependent priors
If X has a single element along the third dimension, then the same prior will be used in each time step. If the third dimension of X has one element per assimilated time step, then each prior will be used for the corresponding time step. For any other number of elements, you will need to use the second input to specify which prior to use in each time step:
```matlab
pf = pf.prior(X, whichPrior);
```
Here, whichPrior is a vector with one element per assimilated time step. Each element of whichPrior indicates which prior (element along dimension 3) to update in the corresponding time step. For example, say I have two priors and seven time steps. If I want to use the first prior to update the first 3 time steps, and the second prior to update the last 4 time steps, I could do:
```matlab
ens1 = ensemble('ensemble-1.ens');
ens2 = ensemble('ensemble-2.ens');
X = cat(3, ens1.load, ens2.load);

nTime = 7;
whichPrior = NaN(1, 7);

whichPrior(1:3) = 1;   % First prior for the first 3 time steps
whichPrior(4:7) = 2;   % Second prior for the last 4 time steps

pf = pf.prior(X, whichPrior);
```

However, you do not need to provide the "whichPrior" input if you already provided it with the [estimates command](estimates).

### NaN Values
A prior can include NaN values, but the final climate state ("analysis") cannot be determined for state vector rows with NaN elements. Consequently, state vector rows with NaN elements will update to NaN in the analysis.
