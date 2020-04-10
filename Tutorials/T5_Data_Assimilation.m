%% Tutorial 5: Run data assimilation

% Great, you've made all the things, let's run some analyses!

% We will work by using specific classes to run different types of
% analyses. Currently, there are classes to implement kalman filters,
% particle filters, and optimal sensor tests. Each does heavy error
 % checking on ensembles, observations, PSMs, and observation
% uncertainties to make sure everything has been prepared correctly for DA.
%
% This tutorial is only for ensemble Kalman filters, but the workflow for
% the other analyses is analogous.

% So, start by creating a kalmanFilter object. Inputs are a model ensemble,
% PSMs, observations and uncertainty.
clearvars;
ens = ensemble('tutorial_sequence.ens');
M = ens.load;
load('tutorial_psms.mat');

% We'll just make some random observations and uncertainties
D = rand(5, 100);
R = ones( 5, 100);

kf = kalmanFilter(M, D, R, F);

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
% "settings" methods

% Let's run using a serial updating scheme, an inflation factor of 3, and a
% localiation radius of 10000 km

% We'll start with the localization radius. The "dash" class provides
% various tools for data assimilation. For most users, the most useful
% methods will be the "localizationWeights" and "regrid" methods. We'll
% come back to "regrid" later, but for now, let's use
% "dash.localizationWeights" to generate the localization scheme.
%
% Provide site coordinates,
% the ensemble metadata object, and the localization radius in km.
w = dash.spatialLocalization( [lats, lons], ens.metadata, 10000);

% Great, let's adjust the settings
kf.settings('type', 'serial', 'inflate', 3, 'localize', w );

% Alright, if we want to see our settings we can do
kf
% and see that our settings have been stored.

% Now, lets run the analysis
output = kf.run

%% Regridding output

% So now we have an output structure with various fields. One of the most
% interesting is often Amean -- that is, the ensemble mean of the analysis.

% Right now it's in state vector form, but we can quickly extract a gridded
% variable from it (or any other state vector) using the "regrid" method

% Inputs are the state vector (or matrix of state vectors), name of the
% variable we wish to extract, and ensemble metadata associated with the state
% vector.
Am = dash.regrid( output.Amean, 'T', ens.metadata );

% We can do
size(Am)
% to see that the product has been regridded

% Although, usually it's useful to also have the metadata associated with
% the grid, which is provided as the second output.
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
% Note that this method requires one additional input. Typically, only the 
% ocean grids from a tripolar coordinate system are use for data assimilation.
% The extra input is simply the indices of these grids in the complete state
% vector.


%% Reconstruct only a few selected variables.

% It is also possible to only reconstruct a few variables for the kalman
% filter. For example, you may need many variables to run some PSMs, but
% are only interested in reconstructing one output variable. 
%
% If an ensemble contains many variables, only reconstructing a few of them
% can greatly speed up the analysis. Note that this is only possible for
% joint updating schemes, or serial updating schemes with appended Ye.

% To only reconstruct specific variables, use the method "reconstructVars".
% Inputs are the desired variables, and metadata for the ensemble.
%
% From our previous examples, let's say we now wish to only reconstruct the
% global temperature variable, but need the full spatial field to run the
% PSMs. Here, we'll use a joint updating scheme with no localization.
kf.settings('type','joint','localize',[]);
kf.reconstructVars( "T_globe", ens.metadata );

% When we run the filter
output = kf.run;

% we can from the size of Amean that only the monthly global mean
% temperature was reconstructed.
size( output.Amean );

% Note that you will need to use modified ensemble metadata when generating
% localization weights or regridding partially reconstructed ensembles. Do
% this via the ensembleMetadata method: "useVars"

% For example, this provides localization weights for the global
% temperature reconstruction
partialMeta = ens.metadata.useVars("T_globe");
w = dash.spatialLocalization( [lats, lons], partialMeta, 10000 );

% (note that the localization weights are now only 12 x 5, rather than the
% previous 82956 x 5).

% Similarly, use the metadata for the partially reconstructed ensemble to
% regrid the output.
Tglobe = dash.regrid( output.Amean, 'T_globe', partialMeta );


%% Limit variables to only the values needed to run PSMs

% Sometimes, it is desirable to only reconstruct a few values from certain
% variables. This is most common for proxy verification analyses. 
%
% For example: Say we have a large gridded ocean variable used to run
% several PSMs. We want to do a proxy validation study, reconstructing
% proxies from the posterior ensemble. We only need a few values from the
% ocean field to run these PSMs, thus don't need to reconstruct the
% *entire* ocean. However, we do need to reconstruct the values used to run
% the PSMs.

% To limit certain variables to PSMs, use the "dash.restrictVarsToPSMs"
% method. Inputs are the PSMs, and either an ensemble object, or its
% metadata. For example, let's look at an intial ensemble and PSMs

ens = ensemble('tutorial_sequence.ens');
M1 = ens.load;
size(M1)
F{1}.H
Y1 = dash.calculateYe( M1, F );

% We can see that M1 is fairly large, and F{1}.H points to certain state
% vector indices. Let's say we actually only need to the parts of the "T"
% variable that are used to run PSMs. We can do
dash.restrictVarsToPSMs( ["T"], F, ens );

% Now if we look at the ensemble and PSMs, we can see that M2 is smaller.
M2 = ens.load;
size(M2)

% And that the PSMs state indices have been updated to reflect the reduced
% ensemble
F{1}.H

% Furthermore, we can check that the Ye values are the same as would have
% been calculated for the full ensemble.
Y2 = dash.calculateYe( M2, F );
isequal( Y1, Y2 );

% Do get covariance localization weights for the new ensemble, proceed as
% normal using
w = dash.spatialLocalization( [lats, lons], ens.metadata, 10000 );