%% Tutorial 1: FILE IO

%% Introduction

% This demonstrates how to create a .grid file from data.
%
% The purpose of a .grid file is to store information in a common data
% format for use with the DASH package.
%
% The methods used for working with .grid files are all stored in the
% gridFile class. See
%
% >> doc gridFile
%
% for details. In the documentation page you will see a section labeled
% "gridFile Methods" up at the top. This lists the functions I think will
% be useful for normal users.
%
% There is also a "Methods Summary" section near the bottom. This is much
% more comprehensive, but only worth learning if you want to develop the
% code.

% The basic workflow for .grid files is:
%   Step 1: Get your data into a Matlab array
%   Step 2: Get metadata for each non-singleton dimension of the array
%   Step 3: Use the array and associated metadata to build a .grid file.
%
%   (Optional) Step 4: If your data is too large to fit in active memory
%   all at once, append sections of your data to an existing .grid file.

% Part of the purpose of the .grid files is to increase workflow
% efficiency. By converting model output fields into .grid files once, you
% are able to use any part of the output field for any subsequent data
% assimilation test. This mitigates time spent downloading files, loading
% them into matlab, etc. Because of this, I recommend using complete model
% output fields to build .grid files, rather than some subset of the field
% that is of interest for current analyses.

% In reality, a .grid file is just a netcdf file that I have ordered in a
% specific manner. So you can use
%
% >> ncdisp( myGridFile.grid )
%
% if you want to see what's under the hood.

%% Make a new .grid file

% We're going to start by extracting data from some file and moving it into
% a Matlab array. In this case, we're going to use output of sea level
% pressure from the last millennium ensemble. Specifically, output from the
% second run over the period January 850 - December 1849.
file = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PSL.085001-184912.nc';

% Extract the variable, and some relevant metadata
PSL = ncread( file, 'PSL');

lat = ncread( file, 'lat' );
lon = ncread( file, 'lon' );
time = datevec(  datetime(850,1,15):calmonths(1):datetime(1849,12,15)  );
run = 2;

% (Note that the time metadata here is in a datevector array, which is just
% my personal preference for working with time metadata. Feel free
% to use whatever format you like!)
%
% ...well almost. Currently, the .grid files only accept numeric metadata,
% so you can't use strings, objects, cells, etc. Again, ONLY NUMERIC
% METADATA. Also important, metadata can be a matrix. In this case, each
% ROW must correspond to one index along the appropriate dimension.
% 
% Vector metadata must have 1 element for each index along the appropriate
% dimension, but you can use a column or a row vector - it doesn't matter.

% Another thing we need to make the .grid file is the order of the
% dimensions in PSL. In the .grid file, the data will be stored in some
% custom dimensional order, but you don't need to worry about that as a
% user. Just provide the order of your data and the code will do all the
% rest.
%
% Looking at the PSL field, we can see it is (144 x 96 x 12000), which is
% longitude x latitude x time. These dimensions have specific names in
% dash. They are lon, lat, and time. In fact, the full set of possible
% named dimensions in dash are 
% 
% lon: Longitude / x-axis
% lat: Latitude / y-axis
% lev: Height / z-axis
% tri: A tripolar dimension (More on this later in the tutorial.)
% time: A time dimension
% run: A model-ensemble dimension
%
% It is the user's responsibility to know the names of dimensions in dash.
% These can all be seen in the function "getDimIDs.m". If you would like to
% rename a dimension (say, from "lat" to "latitude"), you can do so by 
% changing the name in "getDimIDs.m". Similarly, if you find you need more
% than 6 data dimensions, you can add additional dimensions to this
% function. However, for now, I'd recommend leaving it alone.

% So, back to our tutorial on .grid files. The order of dimensions is
dimOrder = ["lon","lat","time"];

% Recall that we noted metadata for the "run" dimension back in line 60.
% Don't we need to note the "run" dimension in the dimension order? What
% about those "tri" and "lev" dimensions in lines 79 and 80?
%
% Short answer: No. You only need to provide names for dimensions that are
% not trailing singletons. But if you want, doing
%
% >> dimOrder = ["lon","lat","time","run"]
%
% will also work fine.


% Another thing needed for the .grid file is the name of any dimension on
% which we might like to append additional data later. I know there are
% multiple ensemble members of the LME, and I also know the data output
% proceeds from 850 - 2005, so I'd like to leave the "time" and "run"
% dimensions available for appending more data later.
appendDims = ["time","run"];


% One last input. Right now, we have metadata for each of the data
% dimensions (lat, lon, time, and run). But what about non-dimensional
% metadata? We can also provide some of those. For those familiar with
% NetCDF files, these are essentially attributes. For .grid files, specify
% these data as a structure.
%
% Worth noting that character metadata *is* allowed in this structure,
% unlike the dimensional metadata.
%
% Here, I'm going to store some information about the data and the model,
% but you can use anything at all. 
specs = struct('Variable','Sea Level Pressure', 'Model', 'CESM Last Millennium Ensemble');


% Okay! We're ready to make a new grid file. Let's call it LME-PSL.grid.
% (Note that you must end the filename with a .grid extension.)
newfile = 'LME-PSL.grid';

% To create the new .grid file, use the command
gridFile.new( newfile, PSL, dimOrder, appendDims, specs, 'time', time, 'run', run, 'lon', lon, 'lat', lat );

% What does this say?
% gridFile is an object that holds functions for working with .grid files
%
% gridFile.new
% says to look in that object and use the function for making new .grid
% files.
% 
% (Note that you can use help commands in the same way as with normal
% functions.)
%
% >> doc gridFile.new
%
% will pull up a reference page on using the method, and
%
% >> help gridFile.new
%
% will print help into the console. Try it out!

% So, back to line 141. It says:
%
% Use the function for making new grid files to create a new file. The name
% of the new file is newfile, the data to store in the file is PSL, the
% order of dimensions in PSL is dimOrder, I want to be able to append along
% the appendDims dimensions later, this data has non-dimensional metadata
% specs, it has "time" metadata equal to time, "run" metadata equal to run,
% "lat" metadata lat, and "lon" metadata lon.
%
% Note that the order you provide the dimensional metadata doesn't matter.
% I could have instead done
%
% >> gridFile.new( ..., 'lat', lat, 'lon', lon, 'run', run, 'time', time )
%
% and it would have been fine.

% Congrats! You made your first .grid file.
%
% (As mentioned before, if you are curious at looking under the hood, you
% can do 
%
% >> ncdisp('LME-PSl.grid')
%
% to see what's inside the .grid file.)

%% Append data to a .grid file.

% As it turns out, the output for the PSL field over every ensemble member
% of the LME is too large to hold in my computer's active memory. To allow
% large data arrays to be stored in .grid files, you can build up the .grid
% files iteratively, by appending new data to an existing array.

% Let's do an example of that now. I mentioned that LME output is over
% 850 - 2005, but we only added data from 850 - 1849 in the previous
% section. Let's add in the remainder of that data.
file = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PSL.185001-200512.nc';
PSL2 = ncread(file, 'PSL');

% Now, the lat and lon data dimensions already have metadata. We don't need
% to provide it again. However, we're adding data along the "time"
% dimension. So we will need to provide metadata for those new time
% indices.
time2 = datevec(  datetime(1850,1,15):calmonths(1):datetime(2005,12,15) );

% Note that we don't need to provide metadata for the existing part of the
% time dimension (the part from 850 - 1849). Instead, just the new indices
% being append along that dimension

% We also need to provide the dimension order for the new data. In this
% case, it is the same order as before, but that is not necessary for
% appending data to .grid files.
dimOrder = ["lon","lat","time"];


% Alright, to append the data, we do
gridFile.append( 'LME-PSL.grid', PSL2, dimOrder, "time", time2 );

% This says, look in the gridFile object and use the function for appending
% data. Append any new data into the existing file 'LME-PSL.grid', append
% the data in PSL2, the dimension order of this new data is 
% lon x lat x time, append the new data along the "time" dimension, the new
% metadata for this dimension is time2.
%
% As usual, you can do
% >> doc gridFile.append
%
% >> help gridFile.append
%
% for help on using the function.

% When appending data, you can only append along 1 dimension. Additionally,
% the new data must be a complete hyperslab of all the other dimensions.
%
% For example, pretend I have PSL data from run 3 that I would like to
% append.
PSL3 = PSL;
run3 = 3;
dimOrder = ["lon","lat","time"];

% Note that this data is only from 850 - 1849, but the data in LME-PSL.grid
% now extends from 850 - 1849. Attempting to append this new data will
% cause an error
gridFile.append( 'LME-PSL.grid', PSL3, dimOrder, "run", run3 );


% Instead, I will need to provide a complete (lon x lat x time) hyperslab.
% So something along the lines of
PSL3 = cat(3, PSL, PSL2);
gridFile.append( 'LME-PSL.grid', PSL3, dimOrder, "run", run3 )

% (Use the append function to add data to 'LME-PSL.grid', the new data is
% PSL3, the order of dimensions is dimOrder, append data to the run
% dimension, the new "run" metadata is run3.



%% Working with tripolar .grids

% Dash requires unique metadata at each index along a data dimension.
% However, this is not the case for tripolar grids. Typically, a tripolar
% grid will have a lat and a lon dimension, but the metadata at each grid
% node will be unique. How to work with this?

% To add a tripolar grid to a .grid file, we will first need to convert the
% tripolar spatial grid to a vector. In this way, each index along the 
% spatial tripolar vector (the tripolar dimension) will be describes by a
% unique lat-lon metadata point.

% Here we will do a demo using SSTs from a run of TRACE
% Start by building a new gridFile
clearvars;

% First, get the data
file = "tos_sfc_Odec_CCSM3_TraCE21ka.nc";
sst = ncread(file, 'tos');

% And the associated metadata
lat = ncread( file, 'lat');
lon = ncread( file, 'lon');
time = ncread( file, 'time');

% Note that lat and lon are matrices here, not vectors.

% Now, convert the tripolar lat-lon spatial grid to a vector
[nLon, nLat, nTime] = size( sst );
sst = reshape( sst, [nLon*nLat, nTime] );

% Get the new "tripolar" metadata
lat = lat(:);
lon = lon(:);
tri = [lat, lon];

% Looking at the tri metadata, we see it is a 2 column matrix. Each row
% corresponds to one index along the tripolar dimension (the vectorized
% lat-lon dimensions), with a unique lat-lon metadata point.
dimOrder = ["tri","time"];
appendDims = [];

% Later, we will see that it can be useful to know the location of land
% elements (NaN values) in a tripolar grid. Let's record those and save
% them to specs.
%
% Remember that specs metadata is limited to numeric values and characters,
% so we will convert the logical indices to singles here.
%
% If you would like to store a matrix of non-dimensional metadata, I
% recommend reshaping it to a row vector, and then saving the original size
% of the matrix as an additional attribute so that you can reshape it back
% to a matrix later.
land = any( isnan(sst), 2 );
land = single(land);
specs = struct('Variable','SST','Model', 'TRaCE', 'land_indices', land );

% Now make the grid file
gridFile.new( 'TRACE-SST.grid', sst, dimOrder, appendDims, specs, 'tri', tri, 'time', time );
