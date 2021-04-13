# Observations
A Kalman Filter analysis proceeds by using observations and proxy measurements (Y) to update a prior ensemble of climate states. These observations are required to run a Kalman Filter analysis.

You can provide the observations for a Kalman Filter using the "kalmanFilter.observations" command. Here, the syntax is:
```matlab
kf = kf.observations(Y);
```
where "Y" is a matrix of observations and proxy measurements. Each row of Y should hold the observations for a particular site, and each column holds observations for an assimilated time step. Use NaN if an observation site does not have a value in a particular time step.

For example, say I have observations from two proxy sites. The first site has observations in time steps 1 through 4, and the second site has observations in time steps 3 through 6:
```matlab
data1 = 11:14;
time_steps_1 = 1:4;

data2 = 103:106;
time_steps_2 = 3:6;
```

Then I could do
```matlab
nSite = 2;
nTime = 6;
Y = NaN(nSite, nTime);

Y(1, time_steps_1) = data1;
Y(2, time_steps_2) = data2;

kf = kf.observations(Y);
```
to provide this data for a Kalman Filter Analysis.
