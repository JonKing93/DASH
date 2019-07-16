%% FILE IO
%
% This demonstrates how to create a .grid file from 

% Get the file name. This is the name of the file containing SST data from
% the 200 year binned Trace run.
file = "tos_sfc_Odec_CCSM3_TraCE21ka.nc";

% Get the SST data
sst = ncread(file, 'tos');

% Get metadata for the grid from the file
lat = ncread( file, 'lat');
lon = ncread( file, 'lon');
time = ncread( file, 'time');

% Provide data for the "run" dimension
%
% This is not strictly necessary, and is being used for the purposes of
% this tutorial to demonstrate the appendGridfile.m function.
run = 1;


% *** Steps unique to tripolar grids ***
% 
% Each index of each dimension of the data in a gridfile must be associated
% with a unique metadata point. Consequently, the gridded metadata
% typically associated with tripolar grids in not permitted.
%
% However, Dash allows each metadata point to be N-dimensional. Thus, to
% place tripolar data in a .grid file, we need to convert the tripolar 
% spatial grid to a vector, and associate each index with a unique 2D
% lat-lon metadata point.
%
% At the end of assimilation, we may want to regrid back to the original
% spatial setup, and we will need the original size of this grid to do so.
% Record this also.
originalSize = size(lat);

% Convert the lat lon metadata to vectors
lat = lat(:);
lon = lon(:);

% Create a single metadata array of unique lat-lon data points. I will
% refer to this vectorized tripolar array as the "tripolar dimension.
tri = [lat, lon];

% Reshape the tripolar sst data to a vector
[nLon, nLat, nTime] = size(sst);
sst = reshape( sst, [nLon*nLat, nTime]);

% One other point for this dataset. Dash does not permit NaN elements to be
% added to the state vector. However, this data set contains a few elements
% that are sometimes NaN, and sometimes not NaN. We will want to store an
% index of the points that are never NaN (i.e. always on the ocean grid) so
% that we do not accidentally try to place these elements in the state
% vector.

% Get an index of the elements that are always on the ocean grid (i.e.
% never are NaN)
ocean = all( ~isnan(sst), 2 );

% *** End steps for tripolar data ***


% Get the order of the data dimensions
gridDims = ["tri", "time"];

% Get the dimension along which additional data may be appended.
%
% I can load this entire dataset into memory without issue, so there are no
% real appending dimensions here. However, for the sake of this tutorial,
% let's assume that I have data from a second run that I will add to this
% grid file later.
appendDims = "run";

% Get the specs structure.
%
% This is a structure that contains any non-gridded metadata I wish to
% record for this dataset. It will be written as a variable attribute in
% the .grid file, thus may have only a single row, and must be a valid
% NetCDF4 data type.
%
% I have provided a function: listnctypes.m
% which details the allowed datatypes.
%
% specs may contain any fields at all. Whatever is useful for the user.
%
% Here, lets specify some baisc information about the model, and the
% variable.
specs = struct('Variable', 'Sea Surface Temperature', 'Units', 'K', ...
               'Model', 'Trace', 'Note', '200 year bins');

           
% *** For tripolar variables ***
%
% The logical index specifying the ocean grids (the non-NaN elements) will
% be useful for regridding the final analysis. Let's save it here in the
% specs structure.
%
% Currently, "ocean" is a logical array, but logicals are uniquely defined
% in Matlab, and not a valid NetCDF4 data type. So we'll convert it to a
% double before adding to specs.
%
% We will also want to record teh original grid size for later regridding

ocean = double(ocean);
specs.ocean = ocean;
specs.gridSize = originalSize;

% *** End tripolar variables ***


% Create a new gridfile
newGridfile('SST-TRACE.grid', sst, gridDims, appendDims, specs, ...
             'tri', tri, 'time', time, 'run', run );
         
% We're done, but for the purposes of the tutorial, say we have data from a
% second run that we wish to add to the grid file.
% 
% % Get mock new data
% sst2 = sst;
% 
% % Specify the dimension along which to append
% appendAlong = "run";
% 
% % Specify metadata for the new index along the run dimension.
% newRun = 2;
% 
% % Add to the gridfile
% appendGridfile( 'SST-TRACE.grid', sst2, gridDims, appendAlong, newRun );
