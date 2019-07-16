%% Run the DA

% For the DA, we will need some PSMs. We'll use UK37 PSMs along with some
% mock data

% Get the lat-lon coordinates of 3 sites and make some mock data for 4 time
% steps.
ukLocation = [27, 34;
              37, 350;
              42, 236];

rng('default');
ukData = rand(3, 4);

% Initialize a cell array to hold the PSM for each site
F = cell(3,1);

% Initialize the PSM for each site. We need to provide the location of each
% site.
for s = 1:3
    F{s} = ukPSM( ukLocation(s,1), ukLocation(s,2) );
    
    % Also, the state vector elements are in unit Kelvin, but the forward
    % model uses Celsius. Specify the unit conversion for each forward
    % model.
    F{s}.setUnitConversion( 'add', -273.15 );
end

% We'll also need to let each PSM know which state vector elements it needs
% to use to run correctly. This is done via the "getStateIndices" method
% of the PSM. We'll need the ensemble metadata to do this. We'll also need
% to tell the PSM what we named the SST variable.
ensMeta = loadEnsembleMeta( 'tutorial.ens' );

for s = 1:3
    F{s}.getStateIndices(ensMeta, "SST");
end

% Load the prior ensemble
M = loadEnsemble( 'tutorial.ens' );

% The last item we need is the uncertainty associated with each
% observation. Make some mock data. 
D = ukData;
R = rand( size(D) );


% Alright, we're ready to run the assimilation. Do so now.
[Amean, Avar] = dash( M, D, R, F );

% % *** INFLATION
% % We could also use an inflation factor
% % [Amean, Avar] = dash( M, D, R, F, 'inflate', 5 );
% 
% % *** LOCALIZATION
% % We can also specify a covariance localization radius. In this case, the
% % radius is 12000 km.
% [w, yloc] = covLocalization( ukLocation, ensMeta, 12000 );
% 
% % The yloc field is a second set of weights used to localize site-site
% % covariance during joint updates. No need to worry about it though. Just
% % place both outputs in a cell, and you're done
% [Amean, Avar] = dash( M, D, R, F, 'localize', {w, yloc} );
%
% % There are many other options and outputs available when running the
% % assimilation. See the documentation in dash.m for details.


% For mapping purposes, we generally want to regrid the state vector to
% some spatial grid. Dash includes built-in regridding functions for this
% purpose. We will need the ensemble metadata a state vector design to do
% this.
[ensMeta, design] = loadEnsembleMeta('tutorial.ens');

% For tripolar regridding, we will need to specify the indices of ocean
% (non-NaN) elements, as well as the original grid size. These were stored
% in the specs structure back in the original 
gridMeta = metaGridfile('SST-TRACE.grid');
ocean = logical( gridMeta.specs.ocean )';
gridSize = gridMeta.specs.gridSize;

sst = regridTripolar( Amean, 'SST', ensMeta, design, ocean, gridSize);

% Note that the final dimension of the regridded sst variable is the DA
% time steps. 
%
% Also note that an update to the tripolar regridding function is in
% progress and that the behavior of this function will likely change in the
% future.
