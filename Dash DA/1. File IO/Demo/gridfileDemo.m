%% This is a demo for gridFile workflow

% Here's the setup. We have a 4 member ensemble of a climate model run on a
% 12.9 x 17.1 (lat-lon) grid. It was run for 12 years with monthly time steps
% Anthropogenic forcing began in year 9. There is a volcanic eruption in 
% January of year 7. The output is saved in some sort of gridded data format
% (probably NetCDF). We want to get this data into a format that is suitable
% for use with dash.
%
% Since climate data can be very large, we don't want to have this all in
% working memory. So, we're going to format the data in a .mat file that
% supports partial loading and partial saving.

%% Create a gridded .mat file

% Load P output and metadata for run 1.
[P, lat, lon, time, run] = someUserFxn(1);

% We can use a command like ncdisp to see that the grid is lon x lat x time. 
% Set this as the grid dimensions
gridDims = {'lon','lat','time'};

% I require the file IO system to track all metadata. To facilitate this in
% the code, I require a specific format for metadata. But the user
% shouldn't have to worry about that, so this next function lets the user drop
% in whatever metadata they have and converts it to my format.
meta = buildMetadata( P, gridDims, 'P', 'time', time, 'lon', lon, 'lat', ...
                      lat, 'time', time, 'run', run );

% Create a gridded matfile.
newGridfile( 'P.mat', P, gridDims, meta );

% There should now be a file, P.mat, on the active path


%% Append new data to the end of a dimension

% Oh hey, this modeling center split its output into pre and post-industrial
% forcing. We want all the data, so let's append the post-industrial output
% to the time dimension.

% Load P for post-industrial, run 1
[P, ~, ~, time, ~] = someUserFxn(2);

% We need to tell the method what dimension to extend (time). Also, since
% we're appending to the end of a dimension, the metadata is just the
% new time data
dim = 'time';
newMeta = time;

% Add to the gridfile.
extendGridfile( 'P.mat', P, gridDims, dim, [], newMeta );


%% Add new data that extends a different dimension and does not specify all
% data values.

% So, some other climate centers are doing post-processing on runs 2 and 3,
% and they're being sloooooow. But we have run 4. We'll add it and leave
% some empty space for the 2nd and 3rd runs.

% Load P for run 3
[P, ~, ~, ~, run] = someUserFxn(3);

% We need to add metadata for ALL new indices (including the ones with
% unspecified data.) So the metadata will be for the 2nd, 3rd and 4th runs.
% (It's the user's responsibility to know the identity of the extra metadata.)
meta = [2 3 run];

% We need to tell the method where to start writing the new data.
dim = 'run';
loc = 4;
% (So, we want to append to the 'run' dimension, starting at run 4).

% Add to the gridfile, extending the run dimension, and writing to the 4th
% run index.
extendGridfile( 'P.mat', P, gridDims, dim, loc, meta );


%% Write data into exisiting indices

% Oh good, run 2 is finished. Let's add that to the reserved index. But
% this other climate center permuted the data dimensions in a different 
% order (what a bunch of weirdos...), so we need to keep track of that.

% Get the data for run 2
P = someUserFxn(4);

% Get the new gridDims (note that lat and lon switched). Even though the
% run dimension is a trailing singleton dimension, we should specify it so
% that we can index to it.
gridDims = {'lat', 'lon', 'time', 'run'};

% Indicate that the writing location should start at run 2. We're going to
% write to all values of lat, lon, and time, so we can leave the starting
% locations for these dimensions as NaN
loc = [NaN NaN NaN 2];

% Add to the gridfile 
indexGridfile( 'P.mat', P, gridDims, loc );


%% Write to specified indices with incorrect metadata.

% Oh good, the other climate center finished run 3. We'll want to add that
% to the file. But hmm, something looks weird about the output, let's check
% that metadata matches just to be safe. This run uses yet another
% permutation of dimensions.

% Get the data
[P, lat, lon, time, run] = someUserFxn(5);
gridDims = {'time', 'run', 'lat', 'lon'};

% Get a metadata structure
meta = buildMetadata( P, gridDims, 'P', 'lat', lat, 'lon', lon, 'time', time, 'run', run );

% Get the starting locations. Note that the dimensions are in a different
% order, so the locs have changed to match that order.
loc = [NaN 3 NaN NaN];

% (Try to) add to the file
try
    indexMetadata( 'P.mat', P, gridDims, loc, meta );
catch
    fprintf( ['Errors!',newline] );
end


%% Write data to index with correct metadata

% So the function threw an error because the metadata didn't match up. Upon
% closer inspection, we see that the output used a different spatial grid.
% After some spatial interpolation, we get the correct grid.
[P, lat, lon, time, run] = someUserFxn(6);

% We're still feeling wary, so we decide to check the metadata again.
meta = buildMetadata( P, gridDims, 'P', 'run', run, 'time', time, 'lon', lon, 'lat', lat );

% Write to the file
indexGridfile('P.mat', P, gridDims, loc, meta);

% Oh good, all the metadata matches


%% Index data to multiple dimensions.

% Alright, this is contrived, but now we want to write to the first four 
% latitudes during the month of January of years 6-8 in run 2.
% Index accordingly.

% Get the data. Again, this grid has a different set of dimensions.
P = someUserFxn(7);
gridDims = {'lat', 'time', 'lon', 'run'};

% Get the locs. Need to specify STRIDE because we're only writing to every
% 12th time index.
loc = [ [1, 5*12+1, NaN, 2];...
        [1,    12,     NaN, 1] ];
% (So, write data starting at the 1st lat index with spacing of 1 lat step.
%  Write at the 61st time index (January year 6) in intervals of 12 time steps.
%  Write at all lon indices
%  Start writing in the 2nd run with an interval of 1 run.)
%
% This is designed to mimic the START and STRIDE variables of ncwrite.
% See the help section of ncwrite for more examples.

% Write
indexGridfile( 'P.mat', P, gridDims, loc );


%% Delete indices

% We've decided that we don't want to include time steps that were affected
% by a large volcanic eruption, so we're going to delete those. We'll
% say that the eruption had large effects for the 2 years following the
% 84th time step. Assume monthly time intervals.

% Get the locations to delete
loc = [84, 1, 24]';
% (So start deleting at the 84th time step, delete with an interval spacing
% of 1, and delete a total of 24 time steps.

% Delete
deleteGridfile( 'P.mat', 'time', loc );


%% Fill Indices

% Oh, so it looks like timesteps 20-50 of run 1 were corrupted (or lost)
% If we delete these time steps, they will be removed from runs 2-4, which
% are not corrupted. But we still want the data in those files. Instead of
% deleting, we'll fill the corrupted timesteps with NaN. This will preserve
% the grid dimensions while removing the corrupted data.

dims = {'time', 'run'};

% Get the locs
loc = [ 20, 1;
         1, 1;
        31, 1; ];
% (Fill from the 20th time step in intervals or 1 time step for 31 steps.
%  Fill in the 1st run in intervals of 1 run, for 1 run.)

% Fill
fillGridfile('P.mat', dims, loc );


%% Look at metadata

% To look at the metadata for a run, use this function
[meta, dimID] = metaGridfile( 'P.mat' );

% There are two outputs here. The first is metadata structure and the
% second is the order of dimensions of the data grid in the .mat file. It
% is unlikely that a user will ever need the second output.

% If you look at meta, you can see everything we fed it at the beginning,
% along with the appended time indices. If you look at the time metadata,
% you can see that the metadata for the deleted volcanic years has also
% been deleted.

% You might also notice a metadata field not mentioned in this demo, 'lev'
% (for level, the vertical coordinate). We didn't provide metadata for this
% field, so the metadata value was just set to NaN. 

% Essentially, this system requires that each grid index has associated
% metadata, but does not require that metadata actually exists. For
% example, if we had no metadata at all, we could do:
P = someUserFxn(1);
gridDims = {'lon','lat','time'};

meta = buildMetadata( P, gridDims, 'P');
% which would build a metadata structure filled with NaN.

% There are also no requirements on what the metadata actually is. For this
% demo, I've used numeric metadata, but we could do strings or structs and
% still be fine. So, for example, if I wanted better descriptions of each
% run, I could do
run = {'Run 1: Run at NCAR, partially corrupted', 'Run 2: Run Elsewhere', ...
        'Run 3: Run elsewhere, different grid', 'Run 4'};

% and all the functions will still work the same.

%% User responsibilities for metadata

% Although the existence and type of metadata have no real restrictions, the
% user does have 2 responsbilities.
%
% 1. They must provide a name for their data variable.
%
% 2. They must know the correct name of each data dimension.


%% Dimensions and Names

% So, what is the "correct" name? It is an ID that this file IO
% system recognizes as the name of a dimension. The names of all possible
% dimensions are in the getKnownIDs.m function in the "User Specified"
% folder. Right now, I've set IDs for 'lat', 'lon', 'time', 'run', and
% 'lev'. 

% These are the only allowed values in any argument involving dimension
% names, such as the gridDims input argument.

% So, if I do
try
    meta = buildMetadata( P, gridDims, 'P', 'latitude', lat);
catch
    fprintf(['Errors!',newline]);
end

% I'll get an error because 'latitude' is not a recognized ID, 'lat' is
% correct name for the y coordinate. But if I like using 'latitude' in my
% workflow, I can just change the string in getKnownIDs from 'lat' to
% 'latitude'.

% However, you  ***SHOULD NOT*** add both 'lat' AND 'latitude' to the list
% of dimension IDs. This is because the list is more than a list of
% recognized names...

%% All Possible dimensions.

% ... Instead, it is a list of all possible dimensions. To make the partial
% loading work later, I keep track of all possible dimensions in each .mat
% file. This is why the metadata in the demo included the 'lev' field. If
% you look at the dimID variable, you'll see that the data in P.mat is
% stored as a lev x run x lat x lon x time grid. Since lev is one of those
% dimensions, it required a metadata index. (Albeit a NaN value...)

% So if you added both 'latitude' and 'lat' to the list of IDs in
% getKnownIDs, they would be treated as two separate dimensions. Each
% dimension can only have one name.

% Incidentally, adding more dimensions to workflow is easy, just add a name
% to getKnownIDs and you're done.