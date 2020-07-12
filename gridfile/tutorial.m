%% Gridfile Tutorial
% This provides a detailed introduction to using the gridfile package.
% Written by Jonathan King

%% Motivation
%
% In many scientific fields, it’s common to use multiple geospatial datasets
% to perform an analysis. For example, I may want to compare temperature data from:
%   1. A climate model simulation,
%   2. An instrumental record, and
%   3. A laboratory reconstruction.
%
% However, different datasets use a variety of different conventions to
% record their data. For example, datasets may save data in different file 
% formats, use different names for the same variables, record variables in
% different dimensional orders, use different units, and use different 
% metadata formats. Furthermore, both data and metadata are often provided 
% in units or formats that are not directly meaningful for users. 
% Consequently, using multiple datasets often necessitates: learning 
% multiple data conventions, loading data from different files, rearranging
% loaded data to fit a desired format, converting data to common units, and
% changing metadata to a more meaningful format. This process is typically 
% both tedious and time-consuming, and gridfile provides a possible solution.
% 
% In brief, gridfile allows values stored in different datasets to be 
% accessed via a single set of common commands. Gridfile is based on the
% idea that data and metadata should be meaningful to the user, so all data
% is organized via the user’s preferred metadata format. Furthermore, 
% gridfile can automatically convert data values to the same units, load
% values in any requested dimensional format, and efficiently access 
% subsets of large datasets. If any of these features sound useful, then
% this tutorial is for you.

%% A quick example
% To illustrate how gridfile can facilitate file I/O, consider the 
% following scenario: Let’s say I want to analyze temperature data from 
% three datasets.
%
% Dataset 1
% Temperature values from a climate model simulation. These temperatures 
% are saved in NetCDF files under the name “tas” with a dimensional order 
% of (longitude x latitude x time). The values are split across two files; 
% the first records temperatures from 850 CE to 1849 CE, and the second 
% records temperatures from 1850 CE to 2005 CE. The time metadata is 
% provided as days since 850 CE, and the temperature values are in units of
% Kelvin. The dataset has a resolution of 2.5 degrees longitude by 4 
% degrees latitude and uses a [0, 360] longitude coordinate system.
%
% Dataset 2
% Temperature values from an instrumental reanalysis. The temperatures are 
% saved in a NetCDF file under the name “TREFHT” with a dimensional order 
% of (latitude x longitude x time). Time metadata is provided as decimal 
% years, and temperature values are in Celsius. The dataset has a 
% resolution of 1 degree longitude by 1 degree latitude and uses a 
% [-180, 180] longitude coordinate system.
%
% Dataset 3
% A laboratory temperature reconstruction. The temperatures are saved in a 
% Matlab .mat file under the name “T” with a dimensional order of
% (time x latitude x longitude). Time metadata is provided as a date vector,
% and temperature values are in Celsius. The dataset has a resolution of 5 
% degrees longitude by 5 degrees latitude and uses a [0, 360] longitude
% coordinate system.
%
% These datasets use many different conventions, and preparing the data for
% analysis will take quite a bit of effort. However, we can use gridfile to
% simplify this process. Without getting into details (that’s the rest of 
% the tutorial!), we can use gridfile to organize and catalogue the values 
% in each dataset. The details for each dataset are saved in a file ending 
% in a .grid extension. For this example, let’s say we named the .grid files:
%
%   1. T-Model.grid
%   2. T-Instrumental.grid, and
%   3. T-Lab.grid
%
% Then the following 5 lines of code:
metadata = gridfile.metadata( gridname );
NH = metadata.lat > 0;
post1800 = metadata.time > 1800;

grid = gridfile( gridname );
[T, Tmetadata] = grid.load( ["time", "lat"], {post1800, NH});

% will allow us to load Northern Hemisphere temperature values post 1800 CE
% from ANY of the three datasets. We’ll also receive metadata for the 
% loaded values. Furthermore, the loaded values and metadata will have:
%    1. The same dimension order – whatever order is requested, here I used time x latitude x longitude.
%    2. The same units – whatever units I prefer, let’s say Celsius.
%    3. The same longitude coordinate system – again, whichever format I prefer, we’ll say I prefer [0 360].
%    4. The same time metadata format – we’ll say I prefer decimal years.
%
% Pretty convenient!

%% How does this work?
%
% (Don’t worry, we’re not going into details here. Just a quick overview to
% illustrate some key concepts.)
%
% N-Dimensional Array
% Ultimately, gridfile relies on instructions saved in a .grid file to load
% values from a dataset. These .grid files do not store any actual data 
% values; instead they organize and catalogue values saved in other files.
% At its most basic, each .grid file manages an N-dimensional data array. 
% This data array does not actually exist, but is an abstraction used to 
% conceptualize how data values in different files fit together.
%
% Unique Metadata
% Each element of each dimension is associated with unique metadata. These
% metadata values are used to index the values in the N-dimensional grid, 
% and can be used to load specific subsets of the full N-dimensional grid. 
% As mentioned, gridfile is based on the concept that metadata should be
% meaningful to the user, so the metadata values for each dimension are 
% specified by the user of the .grid file.
%
% Data Source Files
% When you create a new .grid file, the N-dimensional array is initially 
% empty. However, you can fill the grid with values by adding data source 
% files to the .grid file’s collection. A data source file is a file that 
% has data values saved inside it: for example, a NetCDF or Matlab .mat 
% file. When a data source file is added to a .grid file’s collection, the 
% .grid file determines the location of the data source’s values within the
% N-dimensional array. The .grid file also stores information such as the
% name of the variable in the data source file, the dimension order of that
% variable, any necessary unit conversion, etc. When you make a load 
% request from a .grid file, the file determines which data source files
% hold the requested data. The .grid file then loads the requested data 
% from the relevant files and pieces the loaded data together in the 
% requested format.

%% Create a new .grid file
%
% Define Metadata
% We’ll start by defining the metadata for the .grid file. This metadata 
% specifies the metadata for each dimension in the .grid file, and is used 
% to organize the N-dimensional array. To define metadata, use:
meta = gridfile.defineMetadata(dimension1, metadata1, dimension2, metadata2, ...
                               dimensionN, metadataN );

% Here, the syntax is to provide the name of a dimension and then its
% metadata, then repeat for all dimensions in the dataset. Hence, 
% dimension1, dimension2, …, dimensionN are a set of dimension names. 
% By default, gridfile allows the following dimension names:
"lon"   % for the longitude / x dimension
"lat"   % for the latitude / y dimension
"coord" % for non-regular spatial grids
"lev"   % the level / height / z dimension
"time"  % the time dimension
"run"   % for individual members of an ensemble
"var"   % for different variables on the same spatial/temporal grid

% You DO NOT need to provide metadata for all these dimensions; only the 
% dimensions appearing in your dataset need metadata. Also, you may provide
% the dimensions in any order, regardless of the dimension order of your
% dataset. (If you would like to use different dimension names, you can 
% rename dimensions. If your dataset has more dimenions that the 7 defaults,
% you can add new dimensions).
%
% Next, metadata1, metadata2, …, metadataN are the metadata fields along 
% each specified dimension. Each row of a metadata field is used to index
% one element along a dimension, so each row must be unique. Metadata can 
% use numeric, logical, string, char, cellstring, or datetime formats, but 
% cannot contain NaN, Inf, or NaT elements. In general, it’s best to use 
% metadata values that’s meaningful to you, as this will allow you to reuse
% the .grid file many times in the future. You DO NOT need to use metadata
% values found in data source files.
%
% The following is an example of a typical metadata definition.

lat = (-90:90)';
lon = (0:360)';
time = (850:2005)';
meta = gridfile.defineMetadata("lat", lat, "lon", lon, "time", time);

% Create File
% Now that the metadata is defined, we can create a new .grid file. Here the syntax is:
gridfile.new(filename, meta);

% where filename is the name of the .grid file. Note that gridfile adds a 
% .grid extension if the file name does not already have one, so
gridfile.new('myfile', meta)

% will create a file named “myfile.grid”.
%
% Optional: Include Non-Dimensional Metadata
% You can optionally add non-dimensional metadata to a .grid file as well. 
% For this, use the syntax
gridfile.new('myfile', meta, attributes)

% Here attributes is a scalar structure. It may contain anything at all you
% find useful. For example, you could use:
attributes = struct('Model','CESM-LME','Units','Kelvin');

% to remind yourself of the source of climate model output and the units of
% a dataset. This non-dimensional metadata will be saved to the .grid file
% and is accessible as .grid file metadata.
%
% Optional: Overwrite Existing Files
% By default, gridfile.new will not overwrite an existing .grid file. 
% However, if you wish to enable overwriting, you can set the fourth input 
% argument to true, as per
gridfile.new(filename, meta, attributes, true);

%% Gridfile objects
% Now that we’ve created a .grid file, we’ll want to start adding data 
% sources to it. However, .grid files have a specialized format, so you 
% don’t want to read/write to them directly. Instead we’ll create a 
% gridfile object to interact with a particular file. Create a gridfile 
% object using the gridfile command. For example,
grid = gridfile.new('myfile.grid')

% creates a gridfile object named grid that will allow us to interact
% with ‘myfile.grid’. Throughout the rest of this tutorial, I will use 
% “grid” to refer to a gridfile object. However, feel free to use a
% different naming convention in your own code.

%% Add data sources to a .grid file
%
% Define Source File Metadata
% In order to add a data source file to a .grid file, we will need to 
% define the metadata for the data source. This way, the .grid file can
% locate the data source within the N-dimensional array. We’ve already seen
% how to use “gridfile.defineMetadata” to define metadata for an array, and
% we will use it again here:
sourceMeta = gridfile.defineMetadata(sourceDim1, sourceMeta1, sourceDim2, sourceMeta2, ...
                                     sourceDimN, sourceMetaN);

% as before, the order in which you provide dimensions does not matter. 
% However, the metadata format for each dimension should have the same 
% format as the metadata in the .grid file. For example, if the .grid file 
% uses decimal year time metadata, then you should define time metadata for
% the source files using a decimal year format.
%
% Add Source File
% To add data source files to the .grid file’s collection, use
grid.add(type, filename, variable, dimensionOrder, sourceMeta)

%    type: specifies the type of data source – “nc” for NetCDF files, or “mat” for Matlab .mat files.
%    filename: is the name of data source file.
%    variable: is the name of the variable as it is saved in the data source file.
%    dimensionOrder: is the order of the dimensions of the variable in the data source file.
%    sourceMeta: is the data source file metadata defined above.
%
% If the file name includes a path (for example “\Users\filepath\myfile.nc”), 
% then the matching file is added to the .grid file. If you do not include 
% a path (for example, “myfile.nc”), then the method will search the Matlab
% active path for a file with the matching name.
%
% The following is an example of a typical workflow:
type = 'nc';
filename = 'my-data-file.nc';
variable = 'tas';
dimensionOrder = ["lon","lat","time"];
sourceMeta = gridfile.DefineMetadata("lon", lonMeta, "lat", latMeta, "time", timeMeta);
grid.add(type, filename, variable, dimensionOrder, sourceMeta);

% Important Note: .grid files record the absolute file path of data source 
% files. If you move or rename data source files after adding them to a 
% .grid file, see gridfile.renameSources to rename them in the .gridfile.
%
%
% Non-Regular Grids (Tripolar, Irregular Locations)
% Gridfile organizes data using a regular grid; every dimension element is
% associated with a unique metadata value. However, not all datasets use
% regular grids. For example, tripolar grids are common in climate models
% and apply a unique latitude and longitude coordinate to each grid.
% Similarly, data from irregularly spaced locations (such as instrumental 
% recording stations, or field sites) are also described by a unique
% latitude and longitude coordinate. You can use the “coord” dimension to
% organize non-regular spatial data. When defining “coord” metadata, one 
% possibility is to use a two column matrix where the first column denotes 
% the latitude coordinate, and the second column denotes the longitude 
% coordinate.
%
% Often, non-regular data will still be saved with a latitude and a 
% longitude dimension. For example, say we have tripolar climate model 
% output. This output is saved as (longitude x latitude x time). Longitude 
% metadata for this output (lonMeta) is given as an (nLon x nLat) matrix. 
% The latitude metadata for the output (latMeta) is also an (nLon x nLat) 
% matrix. To define metadata for this data source, we can do
coord = [lat(:), lon(:)];
sourceMeta = gridfile.defineMetadata('coord', coord, ...
                                     dimN, metaN);

% Since we have combined the latitude and longitude metadata into a single 
% “coordinate” metadata, we will need to merge the latitude and longitude
% dimensions when we add the data source file to the .grid file. To do 
% this, we can use
dimensionOrder = ["coord", "coord", "time"];
grid.add(type, filename, variable, dimensionOrder, sourceMeta);

% This combines the first two dimensions (lon and lat) of the variable in 
% the data source into a single “coord” dimension. Note that this feature
% is not limited to the “lat”, “lon”, and “coord” dimensions. In general, 
% any number of dimensions in a data source file can be merged into a
% single dimension by specifying the same dimension name multiple times in
% the dimension order for the add operation.
%
% Optional: Convert Units
% You can optionally have the .grid file convert the units of data values 
% loaded from a particular data source. Gridfile converts units using a 
% linear transformation: Y = aX + b, where X are the values loaded from a 
% data source file and Y are the values returned to the user. To convert 
% the units of values from a data source, use the optional ‘convert’ flag, 
% as per:
grid.add(type, filename, variable, dimensionOrder, sourceMeta, 'convert', convert)

% Here the convert input is a two element vector. The first element 
% specifies the multiplicative constant (a), and the second element 
% specifies the additive constant (b).
%
% Optional: Fill Values and Valid Range
% You can have the .grid file convert data matching a fill value to NaN 
% using the optional ‘fill’ flag
grid.add(type, filename, variable, dimensionOrder, sourceMeta, 'fill', fillValue);

% You can also have the .grid file convert data outside of a valid range to
% NaN using the optional ‘range’ flag
grid.add(type, filename, variable, dimensionOrder, sourceMeta, 'range', validRange);

% Here validRange is a two element vector. The first element is the lower
% bound of the range and the second element is the upper bound.

%% Load data from a .grid file
%
% Load all data
% To load the entire N-Dimensional array use
[X, Xmeta] = grid.load;

% This returns the N-dimensional array (X) and the metadata associated with
% each dimension of the array (Xmeta). The order of the metadata fields 
% will match the order of the dimensions in X.
%
% Request Specific Dimension Order
% When you call grid.load with no inputs, the order of the dimensions of 
% the returned array are determined by an internal gridfile method. However,
% you can instead request that the array be returned with a specific 
% dimension order by specifying a dimension order as the first input. 
% For example:
[X, Xmeta] = grid.load( ["lat","lon","time"] )

% will return the array with a dimension order of 
% (latitude x longitude x time). If you do not specify all the dimensions
% in the .grid file, gridfile will determine the order of the remaining 
% dimensions using an internal method. As always, the order of the metadata
% fields will match the order of the dimensions in X.
%
% Load Data Subset
% Many dataset are too large to load into memory all at once. Instead, 
% we’ll often want to load a small subset of a larger dataset. In gridfile,
% this is accomplished by querying .grid file metadata for specific values.
% To access metadata use:
meta = grid.metadata;

% The returned structure contains the metadata for the specified .grid file.
% Each field of the structure contains the metadata for one dimension. You 
% can use this structure to determine the indices of desired data elements 
% within the .grid file. For example, if we want data values from the 
% Northern Hemisphere, we could do:
NH = meta.lat > 0;

% Or values arranged from 0 to 360 longitude
[~, lon360] = sort(meta.lon);

% Or if we want values after 1800 CE
post1800 = meta.time > 1800;

% Or values at a certain height
high = meta.lev == 250;

%The possibilities are endless! Once we have determined the indices of 
% desired data elements, we can request that the .grid file loads only
% those elements. For example,
[X, Xmeta] = grid.load(["lon","lat","lev","time"], {lon360, NH, high, post1800});

% will load Northern Hemisphere temperatures values at a height of 250 
% after 1800 CE in order from 0 to 360 longitude. The output data will be 
% (longitude x latitude x level x time) and Xmeta will only contain
% metadata for this data subset. Note that the requested indices must occur
% in the same order as the specified dimensions. Gridfile will load all
% elements of dimensions that are not specified. For example, if this 
% dataset also included 5 ensemble members, then the previous call to load
% would load the values for all 5 ensemble members.
%
% Specify order of loaded data values
% If you specify linear indices for a dimension (as opposed to logical 
% indices) gridfile will load the values for the dimension in the specified
% order (just like a normal matlab array). For example, if the values in 
% meta.lon use a [0, 360] coordinate system, then:
[~, lon] = sort(meta.lon);
% would load the data from 0 to 360,

[~, lon] = sort(meta.lon, 1, 'descend');
% will load the data from 360 to 0, and

lon = [5 4 19];
% would load the fifth, then the fourth, and then the nineteenth element 
% along the longitude dimension.
%
% Request dimension order without subsetting a dimension
% If you want to specify a dimension order, but only want to subset a few 
% dimensions, you can use an empty array to load every element from a 
% dimension. For example:
[X, Xmeta] = grid.load(["lon","lat","lev","time"], {NH, [], [], post1800});

% will return X as a (longitude x latitude x level x time) array and will 
% load every element along the latitude and level dimensions.
%
% Optional: Start, Count, Stride Syntax
% gridfile.load also supports the start/count/stride syntax as an 
% alternative to specifying indices. Syntax is
grid.load(dimensions, start, count, stride)

% where start, count and stride are vectors with one element per specified 
% dimension. Start indicates the first index from which to start loading 
% values. Count indicates the number of elements to load along the 
% dimension, and stride indicates the inter-element spacing. If an element 
% of count is Inf, keeps loading values until reaching the end of the 
% dimension. For example:
grid.load(["lat","lon"], [1 5], [6, Inf], [3 4])

% will load 6 latitude elements, starting with the first element and 
% loading every third element after that. This will also load every fourth
% longitude element from the fifth element to the end of the dimension.
% 
% Nice! That’s the tutorial. You're now ready to try out gridfile with your
% own data!