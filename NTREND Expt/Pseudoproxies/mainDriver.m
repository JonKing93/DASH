% This is the driver for the pseudo proxy experiment

%%%%% User specified

% Size of the static ensemble.
nEns = 11 * 10;

% Percent of standard deviation set to R
Rfrac = 0.01;

% Set the months in the seasonal mean
season = [6 7 8];

%%%%%

%% Build the "true" pseudo proxies

% Do the initial linear regression
[linReg, gPseudo] = build_GHCN_linear_model;

% Tune the linear model to the CESM LME means and calculate the
% pseudo-proxies.
[linMod, trueProxy] = build_LME_Pseudos(linReg, gPseudo);

% Save the linear model for use with the linearPSM class
[~,~,~,lon,lat] = loadNTREND;
% save('linear_T_model.mat','linMod','lat','lon');

% Create a linear model
linPSM = linearPSM;

%% Setup for DA

% Build (or load) the static ensemble
% [M, Mmeta] = build_NTREND_Ensemble(nEns, season);
load('testEnsemble_JJA.mat');

D = trueProxy{1}';
R = Rfrac .* D;

% Get the sampling indices
[~,~,~,sLon,sLat] = loadNTREND;
H = samplingMatrix( [sLat, sLon], [Mmeta.lat, Mmeta.lon], 'linear' );

% Get the Ye estimates
Ye = linPSM.buildYe( M(H,:) );

%% Run DA

% Activate the parallel pool
gcp;

% Run vector DA
tic
Avec = vectorDA(M, Ye, D, R, 1);
tvec = toc;

% Run full DA
tic
Afull = fullDA( M, meta, D, R, Hcell, F, 1);
tfull = toc;

% Run linear update DA
tic
Alin = linearDA( M, Ye, D, R, 1);
tlin = toc;