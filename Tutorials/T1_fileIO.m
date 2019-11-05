%% Tutorial 1: FILE IO
clearvars;
close all;
clc;

%% Introduction 

% This demonstrates how to create a .grid file from data.
%
% The purpose of a .grid file is to store information in an organized
% format for the DASH package.
%
% The grid files are serve as containers for various types of stored data,
% including NetCDF files, .mat files, and workspace arrays. For netcdf and
% .mat data sources, associated grid files do not actually store data, but
% rather instructions for how to extract information from the appropriate
% file.
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
%   Step 1: Define metadata for the dimensions of all the gridded data to be
%           placed in the .grid file.
%   Step 2: Initialize a new .grid file.
%
%   Then, for each gridded data source (NetCDF file, .mat file, or
%   workspace array)
%       Step 3: Specify some metadata for the dimensions in the data source.
%       Step 4: Add the data source to the .grid file.

% The purpose of the .grid files is to increase workflow efficiency.
% Storing data in the .grid file limits file IO to a single instance.
% Furthermore, all data is catalogued with associated metadata for use with
% the DASH package, so can be sorted via metadata at any later point.



%% Define metadata.

% Before initializing a new .grid file, we need to specify what data it can
% eventually contain. Do this by defining metadata for each dimension of
% the data that will be added to the file.

% I'll illustrate this with an example case using some output fields from
% the CESM Last Millennium ensemble. 
%
% We're going to be using near-surface temperature (Tref) and
% sea level pressure (SLP) from runs 2 and 3.

% Here are the netcdf files containing the near surface temperature. You
% can see that the files for each run are split into 850-1849, and 1850-2005
trefFiles = ["b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.085001-184912.nc";
             "b.e11.BLMTRC5CN.f19_g16.003.cam.h0.TREFHT.085001-184912.nc"
             "b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.185001-200512.nc"
             "b.e11.BLMTRC5CN.f19_g16.003.cam.h0.TREFHT.185001-200512.nc"];
         
% Similarly here are the files for sea level pressure
pslFiles = ["b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PSL.085001-184912.nc";
            "b.e11.BLMTRC5CN.f19_g16.003.cam.h0.PSL.085001-184912.nc";
            "b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PSL.185001-200512.nc";
            "b.e11.BLMTRC5CN.f19_g16.003.cam.h0.PSL.185001-200512.nc"];
        
% These files are all for data on the CESM-LME model grid. We want to add
% these files to a common .grid file that we can use later for data
% assimilation. We'll want to get all the possible spatial, time, run, and
% variable metadata and use it to define the scope of the .grid file.

% So let's do that now. The spatial metadata can be obtained directly from
% the NetCDF files
lon = ncread( pslFiles(1), 'lon' );
lat = ncread( pslFiles(1), 'lat' );

% Futhermore, we know the total time scope of the files is from 850-2005,
% spaced in monthly increments.
time = ( datetime(850,1,15) : calmonths(1) : datetime(2005,12,15) )';

% Also, these files are for runs 2 and 3. And they define 2 variables
% "Tref" and "SLP"
run = [2;3];
var = ["Tref";"PSL"];

% We'll use these values to create a metadata structure that will define
% the scope of the grid file
meta = gridFile.defineMetadata( 'lon', lon, 'lat', lat, 'time', time, 'run', run, 'var', var );


% So, this line defines metadata for the longitude, latitude, time,
% ensemble, and variable dimensions of our 5 dimensional dataset. We can
% use it now to initialize a new gridFile.
%
% I have used metadata values that I find meaningful, but you may prefer
% completely different metadata. That's fine! You can use any numeric,
% logical, character, string, cellstring, or datetime matrix to define
% metadata for any dimension. 
%
% However, it is important to note that the metadata must have 1 ROW per
% element down the appropriate dimension.

% For example, we could provide more information about the variables in
% their metadata. If we wanted to also provide information about variable
% units, we could do
%   >> var = ["Tref", "Kelvin";   "Slp", "Pa"];
%   >> meta = gridFile.defineMetadata( 'lon', lon, 'lat', lat, 'time', time, 'run', run, 'var', var );


%% Make a new .grid file

% When intializing a new .grid file, we can also provide non-dimensional
% metadata, which I will refer to as attributes. To create attributes for 
% the .grid file, provide a scalar strucutre whose fields contain the 
% values of interest. Again, the metadata is entirely up to you, there are 
% no required fields.
%
% In fact, attributes are entirely optional. You don't need to actually
% provide them when creating a .grid file.

% For this tutorial, let's provide some information about the model and the
% grid
attributes = struct('Model', 'CESM-LME', 'Grid', 'f19_g16');

% Alright, let's initialize the .grid file. We'll call it tutorial.grid
gridFile.new( 'tutorial.grid', meta, attributes );

% this says: Create a new grid file named tutorial.grid,
% the scope of the grid is defined by this metadata,
% the grid also has non-dimensional metadata in attributes.


%% Add data to a grid file

% Alright, now that we've created the grid, we can start adding data. Or
% rather data sources. Instead of taking the time and effort to load data 
% from our netCDF files, merge them together, permute to some dimensional
% order, and save to file (which would duplicate our data), we will instead
% add the netcdf files directly to the data grid. This is far more
% efficient, and allows automated merging of data stored across different
% workspace array, .mat, and NetCDF files.
%
% We will also need to provide some information about the data in data
% source so that the .grid file knows how to access the data at a later
% point.
%
% For a NetCDF file, we need to provide the name of the variable in the
% file, as well as the order of the dimensions of the data. The .grid files
% enforce an internal dimensional order when reading from different data
% sources, but you don't need to worry about it as a user. Simply provide
% the order in the data source, and the .grid file will handle the rest.

% We can look in one of the NetCDF files
ncdisp( pslFiles(1), 'PSL');

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
% var: A dimension for different variables.
%
% It is the user's responsibility to know the names of dimensions in dash.
% These can all be seen in the function "getDimIDs.m". If you would like to
% rename a dimension (say, from "lat" to "latitude"), you can do so by 
% changing the name in "getDimIDs.m". Similarly, if you find you need more
% than 7 data dimensions, you can add additional dimensions to this
% function. However, for now, I'd recommend leaving it alone.

% So, the dimensional order for our files is
dimOrder = ["lon","lat","time"];

% *** Note: The data sources added to a .grid file DO NOT need to store
% data in the same dimensional order. In this tutorial, all the data
% sources will have the same order, but you could easily have a data source
% that is, say lon x lat x time, and a second source that is time x lev x
% lat x lon and be fine. As long as you provide the order of the dimensions
% in the data source, everything will be reordered correctly in the grid.


% Now, we also need to specify the metadata for this data source. That way,
% the .grid file will know which data each data source contains. For these
% files, each NetCDF encompasses a full global spatial grid (so, the same
% lat and lon), one of two time spans, one of 3 runs, and one of two
% variables.

% Here, we'll start with the temperature files. We'll start by defining the
% two time spans
preIndustrial = ( datetime(850,1,15) : calmonths(1) : datetime(1849,12,15) )';
postIndustrial = ( datetime(1850,1,15): calmonths(1) : datetime(2005,12,15) )';

% We can then process each file using a loop. We'll specify the metadata
% for each file, and then add it to the grid
for f = 1:numel( trefFiles )
    
    % Specify metadata
    time = preIndustrial;
    if ismember(f, [3 4])
        time = postIndustrial;
    end
    
    run = 2;
    if ismember( f, [2 4] )
        run = 3;
    end
    
    sourceMetadata = gridFile.defineMetadata('lon',lon, 'lat',lat, 'time', time, 'run', run, 'var', 'Tref' );
    
    % Add the data source
    gridFile.addData('tutorial.grid', 'nc', trefFiles(f), "TREFHT", dimOrder, sourceMetadata );
    
    % so, this says: Add some data to the grid file name 'tutorial.grid',
    % the data I am adding is from a NetCDF file, 
    % the name of the file is in trefFiles, 
    % the name of the variable in the NetCDF is "TREFHT", 
    % the order of the dimensions of this variable is dimOrder, 
    % the data contained in this file is for this metadata.
end

% We can do a similar loop for the PSL files
for f = 1:2:3
    time = preIndustrial;
    if ismember(f, [3 4])
        time = postIndustrial;
    end
    run = 2;
    if ismember(f, [2 4])
        run = 3;
    end
    meta = gridFile.defineMetadata('lat',lat,'lon',lon,'time',time,'run',run,'var',"PSL");
    
    gridFile.addData('tutorial.grid', 'nc', pslFiles(f), "PSL", dimOrder, meta );
end

% Also, note that we can mix the type of data source used in a .grid
% files. For example, say I had PSL data stored in a .mat file named
% "LME_SLP_run4_850-1850.mat", and that the PSL variable was named "SLP" in
% this mat file, and the dimension order is lat x time x lon. Then I could
% do
%
% >> gridFile.addData( 'tutorial.grid', 'mat', "LME_SLP_run4_850-1850.mat", "SLP", ["lat", "time", "lon"], sourceMetadata );
%
% Or if I had the data in an array named X loaded into the workspace, I
% could do
%
% >> gridFile.addData( 'tutorial.grid', 'array', X, [], ["lat","time","lon"], sourceMetadata )
% (Note that workspace arrays are written directly to the .grid file. So
% you can clear your workspace later, and the data will still be
% available.)

% Nice! We've successfully added data to a .grid file. You can stop here if
% you like, but the next two sections explain a few more useful methods for
% working with .grid files

%% Extract grid metadata.

% Later, we will see that it is useful to catalogue data in a .grid file by
% its metadata. To extract metadata for a file, use

meta = gridFile.meta( 'tutorial.grid' );

% By looking at meta, we can see that it contains the metadata for each
% dimension, and also the grid attributes.
disp(meta);


%% Expand a .grid file.

% As more data becomes available over time, it may be desirable to expand
% the scope of the .grid file. For example, in tutorial.grid we added data
% from runs 2 and 3 of CESM-LME. Let's say that run 4 just completed and
% that we would like to add it to the file as well. Currently, the scope of
% the .grid file only covers runs 2 and 3, so we will need to expand its
% scope to cover run 4.
%
% We will expand the scope of the grid file using the "expand" method.
% To use this method, specify the dimension being expanded, and the new
% metadata for the expanded elements.
%
% For this tutorial, let's say we anticipate not just run 4, but also runs
% 5 - 13. Then we can do
newRuns = (4:13)';

% >> gridFile.expand('tutorial.grid', 'run', newRuns );
% so, this says: expand the scope of tutorial.grid,
% expand the run dimension to include 10 new elements,
% the metadata for these 10 new runs are in newRuns.

% (For now, let's hold off on actually expanding this .grid file -- it will
% be more useful this way for later parts of the tutorial.)

%% Rewrite metadata

% Sometimes, it may be necessary to change the format of the metadata. Do
% this using the "rewriteMetadata" method. Syntax is similar to "expand";
% first provide the dimension that is receiving new metadata, then provide
% the new metadata.
%
% For example, perhaps I decided to rename the variables. I can do
newMetadata = ["T";"P"];

gridFile.rewriteMetadata( 'tutorial.grid', 'var', newMetadata );
% this says: rewrite some of the metadata in tutorial.grid,
% specifically rewrite the metadata for the var dimension,
% the new metadata is in newMetadata.


%% Working with tripolar .grids

% Dash requires unique metadata at each index along a data dimension.
% However, this is not the case for tripolar grids. Typically, a tripolar
% grid will have a lat and a lon dimension, but the metadata at each grid
% node will be unique. How to work with this?

% To add a tripolar grid to a .grid file, we will first need to convert the
% tripolar spatial grid to a vector. In this way, each index along the 
% spatial tripolar vector (the tripolar dimension) will be described by a
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

% Define the scope of the grid file
meta = gridFile.defineMetadata('time', time, 'tri', tri );

% Looking at the tri metadata, we see it is a 2 column matrix. Each row
% corresponds to one index along the tripolar dimension (the vectorized
% lat-lon dimensions), with a unique lat-lon metadata point.
dimOrder = ["tri","time"];
appendDims = [];

% Later, we will see that it can be useful to know the location of land
% elements (NaN values) in a tripolar ocean grid. Let's record those and save
% them to the grid attributes.
land = any( isnan(sst), 2 );
attributes = struct('Model', 'TRaCE', 'land_indices', land );

% Now initialize the grid file
gridFile.new( 'trace_sst.grid', meta, attributes );

% And add the data
gridFile.addData( 'trace_sst.grid', 'array', sst, [], dimOrder, meta );

% This says:
% Add a data source to trace_sst.grid,
% The data source is a workspace array,
% Specifically this sst array,
% the order of the dimensions is tripolar (merged lat-lon) x time,
% the array has this metadata.

