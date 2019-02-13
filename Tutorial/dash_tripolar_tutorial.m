%% Demo for working with tripolar coordinates.

%% File IO

% Load SST data from a .nc file. This is from the LME and uses the POP
% ocean grid. You'll need to access it from the Earth System Grid or some
% other data source.
file = 'b.e11.BLMTRC5CN.f19_g16.002.pop.h.SST.085001-089912.nc';
SST = ncread(file, 'SST');

% Look at the grid
ncdisp(file, 'SST');

% We can see that the grid has dimensions TLAT x TLONG x z_t x time, and 
% that its size is nlat x nlon x z_t x time, which is specifically
% 320 x 384 x 1 x 600.
%
% TLAT has the latitude coordinate for each point
% TLONG has the longitude coordinate for each point
% z_t is essentially lev. It is the level in the ocean. Since this is a
%    surface variable, it is a singleton dimension.
% time is time.

% So, we can start by loading TLAT and TLON
TLAT = ncread(file, 'TLAT');
TLON = ncread(file, 'TLONG');

% Looking at the size of these variables
disp(size(TLAT));
disp(size(TLON));

% We can see that they are matrices, rather than vectors. Each set of 
% metadata is nlon x nlat. So, each element in TLAT and TLON display the
% latitude/longitude coordinate for a unique element in the ocean grid.
%
% This is initially problematic for the .grid files. The grid files are
% built to accept vectorized metadata, not grids. This way, each metadata
% value refers to one row of the data hyperslab stored in the .grid file.
%
% (This is essential for various technical reasons that facilitate partial
% loading from .grid files and facilitate fast runtimes for dash.)

% The solution is to convert the spatial ocean grid into a (state) vector.
% This allows conversion of TLAT and TLON to vectors, thereby satisfying
% metadata requirements.

% Alright, now to actually do this:

% I'll start by removing the z_t = lev dimension from the variable. This is
% a completely optional step, and you may wish to preserve the z_t
% dimension. But I'm going to remove it to simplify this demo.
SST = squeeze(SST);

% Alright, now the SST grid is 320 unique lat points x 384 unique lon
% points x 600 time.
disp(size(SST));

% So, reshape the SST grid to a state vector. 
[nlon, nlat] = size(TLAT);
ntime = size(SST,3);

SST = reshape( SST, [nlon*nlat, ntime] );

% Now convert TLAT and TLON to vectors
TLAT = TLAT(:);
TLON = TLON(:);

% This next step may not be intuitive:
%
% It would be incorrect to now insert SST into a .grid file with TLAT and
% TLON as the metadata for the latitude and longitude dimensions.
%
% This is because our SST grid is not lat x lon x time.
% Instead, it is lat-lon x time.
%
% The number of elements in TLAT is NOT EQUAL to nlat. (nlat = 384 and
% the number of elements in TLAT is 122880.)
% Similarly the number of elements in TLON is NOT EQUAL to nlon.
%
% If we used TLAT and TLON as metadata for the lat and lon dimensions, we
% would be saying, 
% "Here is metadata for SST. It has 122880 x 122880  = 1.51E10 elements for each time step."
% In reality, SST has 320 x 384 = 122880 x 1 elements for each time slice.
%
% So, ultimately, each TLAT-TLON pair provides a single coordinate (the
% single metadata value) for some spatial dimension. I will refer to this
% spatial dimension as the "tripole" dimension.

% So, when we build metadata for SST, we need to use tripolar metadata,
% rather than lat and lon metadata

% So, let's create the tripolar metadata. This is very easy, just
% concatenate the TLAT and TLON vectors so that we have a 2 column lat-lon
% matrix. Each row of the matrix specifies the metadata for a specific
% tripolar coordinate
triCoord = [TLAT, TLON];

% Let's get the other metadata and build the metadata structure
time = ncread(file, 'time');
gridSize = [122880, 600];
gridDims = {'tripole','time'};

meta = buildMetadata( gridSize, gridDims, 'SST', 'time', time, 'tripole', triCoord );

% We can then build the .grid file
newGridfile( 'CESM-LME.SST.grid', SST, gridDims, meta );

%% State Design

% There are a few things to keep track of for state vector design workflow.
%
% The first is that we will no longer specify any indices for the lat and
% lon dimensions. Instead, we will specify indices for the tripole
% dimension.
%
% The second is that we will need to screen out land (NaN values) from the
% ocean grid.
%
% Dash cannot perform data assimilation of NaN values because they break
% the covariance matrix. Thus, dash discards state vectors with NaN
% values when building an ensemble.
%
% So, if you do not screen out land (NaN) values from an ocean grid, dash
% will not be able to create a model ensemble. This is because EVERY
% ensemble member in the prior would contain NaN values, and every ensemble
% member would be discarded.

% So, when doing DA with tripolar coordinates, be sure to set the state
% indices to the non-NaN indices.

% In practice, we can find the ocean indices by just checking for NaN
% values in a specific time slice.
ocnDex = ~isnan( SST(:,1) );

% Okay, now we can make the state vector design.
d = stateDesign('My SST design');
d = addVariable( d, 'CESM-LME.SST.grid', 'SST' );

% (Create a state vector design. Add a variable named SST whose data is
% located in the file CESM-LME.SST.grid)

% And then specify the state indices in the design
d = editDesign(d, 'SST', 'tripole', 'state', 'index', ocnDex );

% (Edit the design for the "tripole" dimension of the SST variable. The
% tripole dimension is a state dimension. The state indices are these
% values that only point to the ocean grid cells.)

% and don't forget to specify that time is the ensemble dimension
d = editDesign(d, 'SST', 'time', 'ens' );

%% Regridding

% So we would then build an ensemble
[M, ensMeta] = buildEnsemble(d, 5);

% Build some proxies
% (Your favorite proxies here)

% And run a DA
% (Your favorite analysis here)

% At the end of the DA, we'll have some mean climate state. It will be
% the length of our state vector, so I'm just going to use the first
% ensemble member as our DA output to keep the tutorial simple.
A = M(:,1);

% We can use the regridTripolar function to extract a tripolar variable
% from a DA analysis and covert back to the orignal grid dimensions. To do
% so we will need to specify the ocean indices, as well as the original
% grid size.
[rA, dimID] = regridTripolar( A, 'SST', ensMeta, d, ocnDex, [320 384] );

% We can look at the dimension IDs
disp(dimID);

% And see that this grid is tri1 x tri2. That is, tripolar coordinate 1,
% and tripolar coordinate 2. Dash is designed to regrid generally to any
% input tripolar grid, so it is the user's responsibility to know that tri1
% is TLAT, and tri2 is TLONG.
%
% Note that if we had used any sequences (like a series of months) in the
% state design, then the dimension with sequences (time) would not be a
% singleton, and the grid might be tri1 x tri2 x time. This would be
% recorded in the dimID output variable.