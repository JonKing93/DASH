---
sections:
  - Percentiles
  = Delete percentiles
  - Output field  
---
# Percentiles output
You can use "kalmanFilter.percentiles" to return percentiles of the posterior ensemble as output. Here the syntax is:
```matlab
kf = kf.percentiles( percs );
```
where "percs" is a vector of percentiles between 0 and 100. As opposed to ensemble deviations, ensemble percentiles can be a more memory efficient way to examine the spread of the posterior.

For example, if I want to return the 25th, 50th, and 75th percentiles of the posterior ensembles, I could do:
```matlab
percs = [25 50 75];
kf = kf.percentiles( percs );
```
to return them.

### Delete percentiles
You can clear any specified percentiles by calling the "percentiles" command with no inputs. For example, if I previously used:
```matlab
kf = kf.percentiles( [25 50 75] );
```
then I could do
```matlab
kf = kf.percentiles;
```
to disable any calculated percentiles as output.

### Output field
If you return posterior percentiles, then the output of a Kalman Filter analysis will include a field named "Aperc". This will hold the posterior ensemble percentiles in each time step and will have size (State vector x Percentiles x Time). Note that the order of percentiles in the output field will be the same order as the "percs" input.
