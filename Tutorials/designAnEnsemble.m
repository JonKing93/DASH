% Building the ensemble.
%
% Our model data is now organized into a grid file. This is a general
% container that we can use for multiple assimilations.
%
% For a specific assimilation, we will need to specify which portion of the
% data we want to use. This is done by creating a special object that
% contains instructions on how to build a state vector (i.e. a stateDesign
% object)
clearvars;

% Initialize and name a new stateDesign object
design = stateDesign('My tutorial design');

% Add a variable to the state vector. Specify the file containing the
% variable, as well as the name you prefer to use for the variable.
design = addVariable( design, 'SST-TRACE.grid', 'SST' );

% We now need to edit this variable so that the correct elements are used
% for the assimilation. For this tutorial, let's say that we only want data
% from before -0.5 ka BP.

% The metadata in the gridfile will help with this. Get that now.
meta = metaGridfile( 'SST-TRACE.grid' );

% Get the indices of the data we want
timeIndex = meta.time < -0.5;

% As mentioned previously, dash will not accept NaN elements in the state
% vector. So we should also be careful to not use any of those NaN points.
% We can do this using the index of ocean cells stored in the specs
% structure. Use this to help select the tripolar dimension indices.
ocean = logical( meta.specs.ocean )';

% Specify the tripolar indices to use for the variable named 'SST'. The
% tripolar indices are a state dimension. That is, each state vector
% element is associated with a unique tripolar metadata point. Specify this
% also.
design = editDesign( design, 'SST', 'tri', 'state', 'index', ocean );

% The time dimension is an ensemble dimension. That is, each ensemble
% member in the model prior is associated with a unique time metadata
% point. Specify this along with the time indices.
design = editDesign( design, 'SST', 'time', 'ens', 'index', timeIndex );


% Alright, the design is complete. Let's create the ensemble. We'll do a
% 100 member ensemble. The ensemble will be saved to file along with
% associated metadata, so we will also need to specify the file name.
nEns = 100;
buildEnsemble( design, nEns, 'tutorial.ens');

% Perhaps we decide that 100 ensemble members is too small and that we
% actually want a 115 member ensemble. We can increase the size using the
% addToEnsemble.m function
nAdd = 15;
addToEnsemble( 'tutorial.ens', nAdd );

% Later, we may wish to have the metadata associated with this ensemble.
% Here is how to load it.
ensMeta = loadEnsembleMeta( 'tutorial.ens' );

% Alternatively, load the metadata from a state vector design.
% ensMeta = loadEnsembleMeta( design );