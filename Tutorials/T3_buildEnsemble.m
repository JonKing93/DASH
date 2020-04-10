%% Tutorial 3: Build an ensemble
clearvars;

%% Make the design
% 
% The basic workflow for building an ensemble in dash is
% 1. Design a state vector
% 2. Write an ensemble to a .ens file
% 3. Load the ensemble

% I'll start off by quickly making the state design we made in Tutorial 2.
% (PSL NH JJA mean, with PSL JJA global mean)
file = 'tutorial.grid';
meta = gridFile.meta(file);
d = stateDesign('tutorial');
d = d.add( 'PSL', file );
d = d.add( 'PSL_globe', file);

d = d.edit( 'PSL', 'var', 'state', 'index', 2 );
d = d.edit( 'PSL', 'time', 'ens', 'index', month(meta.time)==6, 'mean', [0 1 2]);
d = d.edit( 'PSL', 'run', 'ens');
d = d.copy( 'PSL', 'PSL_globe');

d = d.edit( 'PSL', 'lat', 'state', 'index', meta.lat>0 );
d = d.edit( 'PSL_globe', 'lat', 'state', 'mean', true );
d = d.edit('PSL_globe', 'lon', 'state', 'mean', true );


%% Build the ensemble

% This is a rather easy step. stateDesign objects have the method
% "buildEnsemble" which writes an ensemble to a .ens file. To use the
% method, specify the number of ensemble members, and the name of the .ens
% file.
ens = d.buildEnsemble( 50, 'tutorial.ens');

% You can also optionally specify whether the ensemble should be drawn at
% random or selected in order.
%
% Ordered selection can be useful if you want to maintain a time structure
% within the ensemble. I often find it useful when designing target fields
% for pseudo-proxy experiments.
ens2 = d.buildEnsemble( 50, 'tutorial_ordered.ens', false );

% Finally, you can note to overwrite exisiting files if desired. The line
try
    ens = d.buildEnsemble( 50, 'tutorial.ens' );
catch ME
    disp( ME.message )
end

% will now throw an error. But
ens = d.buildEnsemble( 50, 'tutorial.ens', true, true );

% will not.

%% The ensemble object.

% Note that the output of buildEnsemble, ens, is an "ensemble" object.
%
% This stores metadata on the ensemble, and allows you to interact with the
% saved ensemble without ever bothering with the .ens file.

% Some useful fields of the ensemble object include
ens.random
% which indicates whether the ensemble is drawn randomly or ordered

ens.design
% The state design used to create the ensemble

ens.metadata
% A metadata object often useful for PSMs

ens.ensSize
% The size of the ensemble

ens.hasnan
% Whether an ensemble member has any NaN values

% See
% >> doc ensemble
%
% For available methods.

% Currently, there are only two methods. "add" and "load"

%% Add to ensemble

% Use the add method when you want to add more ensemble members to an
% existing ensemble.

% For example, if we do
ens.ensSize

% we can see that the ensemble we built has 6913 state vector elements,
% and 50 ensemble members.

% But we can do
ens.add( 5 );

% To add 5 more ensemble members
% Check out
ens.ensSize

%% Load an ensemble

% To actually load the ensemble into memory, use
M = ens.load;

% This returns the actual ensemble data array stored in the .ens file.

% It is also possible to only load a few specific ensemble members or a few
% specific variables. Specify which ones you want, and then load.
%
% For example, the following lines cause only the first, fifth and 55th
% ensemble members of the global mean PSL variable to be loaded.
ens.useMembers( [1 5 55] );
ens.useVars( "PSL_globe" );
M = ens.load; 

%% Ensemble metadata
ens = ensemble('tutorial.ens');

% The field
ens.metadata

% Stores comprehensive metadata for the ensemble. It is often useful for
% PSMs, and can be provided directly via line 114.
%
% If you would like to interact directly with the ensemble metadata, please
% see
%
% >> doc ensembleMetadata 

% If you would like to check the metadata of certain
% state vector indices (perhaps to make sure that the ensemble was built
% correctly, use the "lookup" method.
%
% Inputs for this method are the dimensions of interest, and the state
% vector indices at which you would like to lookup data
[meta] = ens.metadata.lookup( ["lat","lon", "time"], [5:10] );

disp([meta.lat, meta.lon])

% Here we can see the lat-lon coordinates of state vector elements 5-10.

% Note that 
meta.time

% is all NaN, because time is an ensemble dimension. If we had used a
% sequence for time, then meta would show the sequence metadata.

% Sometimes, you may want to use ensemble metadata without actually
% building or loading an ensemble. If this is the case, you can generate an 
% ensembleMetadata object using either a stateDesign object, or the name
% of an existing .ens file as the input. For example 
ensMeta2 = ensembleMetadata( d );
ensMeta3 = ensembleMetadata( 'tutorial.ens' );

% If you specified specific ensemble members or variables, you can get the
% metadata for just the loaded data by calling ens.metadata
%
% For example, after calling
ens.useMembers( [1 5 55] );
ens.useVars( "PSL_globe" );

% The command
ensMeta = ens.metadata;

% returns the metdata structure for the 5 member, global PSL ensemble


%% Existing ensembles

% If you previously wrote a .ens file. Do
% >> ens = ensemble( fileName );

% to get the associated ensemble object. For example:
clearvars;
ens = ensemble('tutorial.ens');


%% Run this, but ignore this, it's for the next tutorial.

file = 'tutorial.grid';
meta = gridFile.meta(file);
months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
d = stateDesign('tutorial');
d = d.add( 'T', file );
d = d.add( 'T_globe', file);
d = d.edit( 'T', 'time', 'ens', 'index', month(meta.time)==1, 'seq', 0:11, 'meta', months);
d = d.edit( 'T', 'run', 'ens');
d = d.edit( 'T', 'var', 'state', 'index', 1 );
d = d.copy( 'T', 'T_globe');
d = d.edit( 'T', 'lat', 'state', 'index', meta.lat>0 );
d = d.edit( 'T_globe', 'lat', 'state', 'mean', true );
d = d.edit('T_globe', 'lon', 'state', 'mean', true );

d.buildEnsemble(10,'tutorial_sequence.ens');