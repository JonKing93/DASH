---
sections:
  - Prior
  - NaN values
---
# Prior
You must provide a prior ensemble (X) in order to run an optimal sensor experiment. The prior ensemble is used to generate a probability distribution for the reconstruction target. It optionally may also be used to run PSMs and dynamically generate observation estimates.

You can provide a prior using the "optimalSensor.prior" command. Here the syntax is:
```matlab
os = os.prior(X);
```
where X is a matrix with a state vector ensemble. Each row holds a particular state vector element, and each column is an ensemble member.

### NaN Values
A prior can include NaN values, but these cannot be used to generate a probability distribution for the reconstruction target and cannot be used to run PSMs.
