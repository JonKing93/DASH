%% Tutorial 5: Run data assimilation

% Great, you've made all the things, let's run some analyses!

% Run an analysis using a "dash" object. This is a workspace that does
% heavy error checking on ensembles, observations, PSMs, and observation
% uncertainties to make sure everything has been prepared correctly for DA.
%
% It also provides a flexible workspace in which to switch between ensemble
% kalman filter analyses, particle filters, and optimal sensor analyses.
%
% This tutorial is only for ensemble Kalman filters, but let me know if
% you'd like help with the others!

% So, start by creating a dash object. Inputs are a model ensemble, PSMs,
% observations and uncertainty.
clearvars;
ens = ensemble('tutorial_sequence.ens');
M = ens.load;
load('tutorial_psms.mat');

% We'll just make some random observations and uncertainties
D = rand(5, 100);
R = ones( 5, 100);

da = dash(M, D, R, F);

% Some notes: You can provide either an ensemble object, OR the associated
% ensemble data array to dash. The ensemble object is useful for methods
% that operate on ensembles too large to fit into memory. But the data
% array is generally faster if possible.

% Also: You can provide R as a scalar (same uncertainty all observations
% all time steps), row vector( same uncertainty all observations but unique
% for each time step), column (unique observations same in all time steps),
% or as a matrix (unique for both observation and time step).

%% Adjust analysis settings

% The settings for different analyses are altered via the
% "ensrfSettings"
% "pfSettings", and
% "sensorSettings"
% 
% methods

% Let's run using a serial updating scheme, an inflation factor of 3, and a
% localiation radius of 10000 km

% We'll start with the localization radius. Use the method
% "dash.localiationWeights" to generate weights. Provide site coordinates,
% the ensemble metadata object, and the localization radius in km.
w = da.localizationWeights( [lats, lons], ens.metadata, 10000);

% Great, let's adjust the settings
da.ensrfSettings('type', 'serial', 'inflate', 3, 'localize', w );

% Alright, if we want to see our settings we can do
da.settings.ensrf
% and see the changes we just made.

% Now, lets run the analysis
output = da.ensrf;

%% Regridding output

% So now we have an output structure with various fields. One of the most
% interesting is often Amean -- that is, the ensemble mean of the analysis.

% Right now it's in state vector form, but we can quickly extract a
% variable from it (or any other state vector) using the "regrid" method

% Inputs are the state vector (or matrix of state vectors), name of the
% variable we wish to extract, and ensemble metadata associated with the state
% vector.
Am = dash.regrid( output.Amean, 'T', ens.metadata );

% We can do
size(Am)
% to see that the product has been regridded

% Although, usually it's useful to also have the metadata associated with
% the grid
[Am, meta] = dash.regrid( output.Amean, 'T', ens.metadata );

% Here
meta.lat
meta.lon
% show the lat and lon metadata along each dimension

% and
meta.time
% shows the sequence metadata associated with the 12 time dimension
% indices.

%% Regridding tripolar

% Note that tripolar grids use the method "regridTripolar" to return to the
% original grid. (Calling "regrid" will still keep the tripolar spatial
% dimension as a single vector.)
%
% Note that this method accepts one additional input. For the tutorial,
% TRaCE grid, this is the land/ocean indices we saved into the attributes
% structure in the first tutorial.