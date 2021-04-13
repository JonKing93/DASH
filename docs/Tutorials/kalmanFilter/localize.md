
# Covariance Localization

Covariance localization reduces covariance as grid points become more distant from the proxy sites. This allows nearby proxy sites to most strongly influence updated grid points, and helps reduce covariance biases at distant points. The basic workflow for localization is to:

1. Obtain spatial coordinates of the state vector elements and proxy sites,
2. Calculate localization weights using the distances between these coordinates, and
3. Provide the localization weights to the Kalman Filter object.

The most commonly used localization scheme is a Gaspari-Cohn polynomial applied over two dimensions, and the tutorial will focus on implementing this scheme.

### 1. Obtain spatial coordinates
The Gaspari-Cohn polynomial considers distances based on the latitude and longitude of assimilated grid points and proxy sites. You can acquire latitude-longitude coordinates for a state vector using the [ensembleMetadata.latlon command](..\ensembleMetadata\latlon). For example:
```matlab
ens = ensemble('my-ensemble.ens');
coords = ens.metadata.latlon;
```

The coordinates of proxy sites might be stored in data file. For example:
```matlab
proxyData = load('my-proxy-data.mat', 'coordinates');
proxyCoords = proxyData.coordinates;
```

Alternatively, if you have organized proxy data in a gridfile, you may be able to access proxy coordinates via the gridfile metadata. For example:
```matlab
proxies = gridfile('my-proxies.grid');
meta = proxies.metadata;
proxyCoords = meta.coord;
```

### 2. Calculate Localization Weights

Localization weights are the weights that reduce estimated covariance values in a Kalman Filter. You can generate these weights using the command "dash.localizationWeights":
```matlab
[wloc, yloc] = dash.localizationWeights(name, ..);
```
Here, "name" is a string that identifies the localization scheme being used. This will be followed by additional arguments, which will vary with the localization scheme being used. The output "wloc" is a matrix with localization weights that reduce the covariance between assimilated grid points and proxies sites. It has dimensions (State Vector x Proxy Sites). The output "yloc" is a symmetric matrix with weights that reduce the covariance of proxy sites with other proxy sites. It has dimensions (Proxy Sites x Proxy Sites).

To implement a Gaspari-Cohn 2D localization scheme, we will use "gc2d" as the name of the localization scheme. The syntax for this scheme is:
```matlab
[wloc, yloc] = dash.localizationWeights("gc2d", coords, proxyCoords, R);
```
Here, "coords" and "proxyCoords" are the state vector and proxy coordinates obtained in the previous section. R is a scalar that specifies the localization radius in kilometers. Outside of this radius, proxy covariances are set to 0.

For example, if I wanted to calculate weights using a localization radius of 30,000 kilometers, I could do:
```matlab
[wloc, yloc] = dash.localizationWeights("gc2d", coords, proxyCoords, 30000);
```

### 3. Provide localization weights to the Kalman Filter

Once you have calculated localization weights, you can provide them to a Kalman Filter object using the "localize" command:
```matlab
kf = kf.localize(wloc, yloc);
```

### Summary

Putting it all together, localization workflow often resembles the following:
```matlab
% Get state vector coordinates
ens = ensemble('my-ensemble.ens');
coords = ens.metadata.latlon;

% Get proxy coordinates
proxies = gridfile('my-proxies.grid');
proxyCoords = proxies.metadata.coord;

% Calculate localization weights
radius = 30000;
scheme = "gc2d"; % Gaspari-Cohn polynomial in 2D
[wloc, yloc] = dash.localizationWeights(scheme, coords, proxyCoords, radius);

% Pass weights to the Kalman Filter
kf = kf.localize(wloc, yloc);
```

### Use different localization weights in different time steps

You can also use different localization weights in different assimilated time steps using a third input to the "localize" command:
```matlab
kf = kf.localize(wloc, yloc, whichLoc);
```
In this case, wloc and yloc will have 3 dimensions, and the different sets of localization weights are organized along the third dimension. The input "whichLoc" is a vector with a length matching the number of assimilated time steps; each element indicates which set of localization weights to use for a given time step, and each value is the index of the appropriate set of localization weights along the third dimension of wloc and yloc.

For example, let's say I have proxy observations in 1150 time steps. I want to use a localization radius of 30,000 km for the first 1000 time steps, and then a radius of 20,000 km for the last 150 time steps. Then I could do:
```matlab
% Get the sets of localization weights
[wloc1, yloc1] = dash.localizationWeights("gc2d", coords, proxyCoords, 30000);
[wloc2, yloc2] = dash.localizationWeights("gc2d", coords, proxyCoords, 20000);

% Organize the sets of weights along the third dimension
wloc = cat(3, wloc1, wloc2);
yloc = cat(3, yloc1, yloc2);

% Use the first set of weights for the first 1000 time steps
% Then use the second set of weights for the last 150 time steps
whichLoc = [ones(1000,1); 2*ones(150,1)];
kf = kf.localize(wloc, yloc, whichLoc);
```
