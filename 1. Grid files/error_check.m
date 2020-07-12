%% This does an error check on the gridfile package.
clear;
clc;

% Start by creating a new gridfile
full = 'D:\Climate Data\Models\CESM LME\TREFHT, Near surface air temperature\Raw\b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.085001-184912.nc';
f1 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.085001-184912.nc';
f2 = 'T-run2-1850,2005-time,lon,lat.mat';


%% Test metadata definition
lat = ncread(full,'lat');
lon = ncread(full,'lon');
time = (datetime(850,1,15):calmonths(1):datetime(2010,12,15))';
run = 2;

% Duplicate dimension name
try
    gridfile.defineMetadata('lat', lat, 'lat', lon);
catch
    fprintf('Successfully caught duplicate dimension name.\n');
end

% Unallowed metadata
try
    gridfile.defineMetadata('lat', {1234});
catch
    fprintf('Successfully caught unallowed metadata.\n');
end
try
    gridfile.defineMetadata('lat', rand(5,5,5));
catch
    fprintf('Caught non-matrix metadata.\n');
end
try
    gridfile.defineMetadata('lat', [lat(1), lat(1)]');
catch
    fprintf('Caught duplicate metadata.\n');
end

% Correct build
meta = gridfile.defineMetadata('lat', lat, 'lon', lon, 'time', time, 'run', run);
fprintf('Built metadata.\n');

%% Create new file

if isfile('myfile.grid')
    delete('myfile.grid');
end
if isfile('merge.grid')
    delete('merge.grid');
end

% Check .grid append
file = 'myfile';
gridfile.new(file, meta);
if isfile('myfile.grid')
    fprintf('Appended extension\n');
end

% Catch unallowed atts
try
    gridfile.new(file, meta, 5);
catch
    fprintf('Caught unallowed attributes.\n');
end
atts = struct('Model','LME','Units','Kelvin');
try
    gridfile.new(file, meta, [atts, atts]);
catch
    fprintf('Caught multiple attributes.\n');
end

% Don't overwrite file
try
    gridfile.new(file, meta, atts);
catch
    fprintf('Caught file overwrite.\n');
end

% Overwrite
gridfile.new(file, meta, atts, true);
fprintf('Successfully overwrote file.\n');

%% Create .grid object
file = 'myfile.grid';
grid = gridfile(file);
if isa(grid, 'gridfile')
    fprintf('Built gridfile object.\n');
end

%% Add data sources

meta = gridfile.defineMetadata('lat',lat,'lon',lon,'time',time(1:12000),'run',2);
dimOrder = ["lon","lat","time"];

% Unrecognized type
try
    grid.add('blarn', full, 'TREFHT', dimOrder, meta);
catch
    fprintf('Caught unrecognized type.\n');
end

% Incorrect type
try
    grid.add('mat', full, 'TREFHT', dimOrder, meta);
catch
    fprintf('Caught incorrect type.\n');
end

% Add full off of path
addpath(genpath("D:\Climate Data"));
rmpath(genpath("D:\Climate Data"));
grid.add('nc', full, 'TREFHT', dimOrder, meta);
fprintf('Found full path\n');
grid.remove(full);

% Find name on path
addpath(genpath("D:\Climate Data"));
grid.add('nc', f1, 'TREFHT', dimOrder, meta);
fprintf('Found on active path.\n');
grid.remove(full);

% Incorrect variable
try
    grid.add('nc', full, 'blarn', dimOrder, meta);
catch
    fprintf('Caught incorrect variable\n');
end

% Unrecognized metadata
bad = gridfile.defineMetadata('lat', lat, 'lon', lon+600, 'time', time, 'run', run);
try
    grid.add('nc', full, 'TREFHT', dimOrder, bad);
catch
    fprintf('Caught unrecognized metadata.\n');
end

% Different order
bad = lon;
bad(1) = lon(2);
bad(2) = lon(1);
bad = gridfile.defineMetadata('lat',lat,'lon', bad,'time',time,'run',run);
try
    grid.add('nc',full,'TREFHT',dimOrder, bad);
catch
    fprintf('Caught incorrect order.');
end

% Missing dimensions
bad = gridfile.defineMetadata('lon', lon,'time',time,'run',run);
try
    grid.add('nc', full, 'TREFHT', dimOrder, bad);
catch
    fprintf('Caught missing dimensions.\n');
end

% Incorrect dimension order
try
    grid.add('nc',full,'TREFHT', ["time","lon","lat"], meta);
catch
    fprintf('Caught incorrect rows / wrong dimension order.\n');
end

% Allow missing singletons
allowed = gridfile.defineMetadata('lat',lat,'lon',lon,'time',time(1:12000));
grid.add('nc', full, 'TREFHT', dimOrder, allowed);
fprintf('Allowed singletons\n');
grid.remove(full);

% Add post-processing
val1 = ncread(full, 'TREFHT', [1 1 1], [1 1 1]);
grid.add('nc', full, 'TREFHT', dimOrder, meta, 'convert', [1 -273.15], 'fill', val1);

meta.time = time(12001:13872);
range = [186 300];
grid.add('mat', f2, 'T', ["time","lon","lat"], meta, 'validRange', range, 'convert', [1 -273.15]);
fprintf('Added post-processing.\n');

fprintf('Built grid. \n');

% Merge dimensions
latgrid = repmat( lat', [numel(lon), 1]);
longrid = repmat( lon, [1 numel(lat)]);
coord = [latgrid(:), longrid(:)];
mergemeta = gridfile.defineMetadata('coord', coord, 'time', time, 'run', run);
merge = gridfile.new('merge', mergemeta, atts);

mergemeta.time = time(1:12000);
merge.add('nc', full, 'TREFHT', ["coord","coord","time"], mergemeta,'convert', [1 -273.15], 'fill', val1);
mergemeta.time = time(12001:13872);
merge.add('mat', f2, 'T', ["time","coord","coord"], mergemeta, 'validRange', range, 'convert', [1 -273.15]);
fprintf('Merged dimensions.\n');

%% Load metadata
meta = grid.metadata;
if ~isfield(meta, 'attributes')
    error('bad');
end
fprintf('Included attributes\n');

%% Display info

grid.info
fprintf('Displayed info.\n');
grid.info(f2);
fprintf('Included source from file.\n');
grid.info(2);
fprintf('Included source from index.\n');
grid.info('all');
fprintf('Included all sources.\n');
[gridInfo, sourceInfo] = grid.info('all');
fprintf('Returned info structures\n');

%% Load

% Data from files
T1 = ncread(full, 'TREFHT');
T2 = matfile(f2);
T2 = T2.T;

T1(T1==val1) = NaN;
T2(T2<range(1) | T2>range(2)) = NaN;
T1 = T1 - 273.15;
T2 = T2 - 273.15;
fileT = cat(3, T1, permute(T2, [2 3 1]), NaN(144, 96, 60));

% Complete grid
[T, Tmeta] = grid.load;
fprintf('Loaded grid.\n');

% Check values
if ~isequaln( T, fileT )
    error('bad');
end
fprintf('Checked values.\n');

% Check for NaN infilling
if ~all(isnan(T(:,:,13873:end)),'all')
    error('bad');
end
fprintf('Infilled NaNs\n');

% Request dimension order
[T, Tmeta] = grid.load(["run","lat","time","lon"]);
if ~isequal(size(T), [1 96 13932 144])
    error('bad');
end
fprintf('Ordered dimensions.\n');

% Check reordering values
if ~isequaln(T, permute(fileT, [4 2 3 1]) )
    error('bad');
end
fprintf('Checked values.\n');

% Subset data
lons = [2 6 3 19];
lats = meta.lat>0;
times = year(meta.time)>1800 & year(meta.time)<1900;
[T, Tmeta] = grid.load( ["lon", "lat", "time"], {lons, lats, times} );
fprintf('Loaded subset\n');

% Check subset values
filesub = fileT(lons, lats, times);
if ~isequaln( T, filesub )
    error('bad');
end
fprintf('Checked values\n');

% Check subset metadata values
if ~isequal(meta.lon(lons), Tmeta.lon)
    error('bad');
end
fprintf('Checked metadata values\n');

% Exclude a source
times = year(meta.time)>1800 & year(meta.time)< 1806;
[T, Tmeta] = grid.load( ["lon", "lat", "time"], {lons, lats, times} );
fprintf('Excluded source\n');

% Check subset values
filesub = fileT(lons, lats, times);
if ~isequaln( T, filesub )
    error('bad');
end
fprintf('Checked values\n');

% Merge values
[T, Tmeta] = merge.load;
fprintf('Merged dimensions\n');

% Check values
siz = size(fileT);
filesub = reshape(fileT, [siz(1)*siz(2), siz(3)]);
if ~isequaln(T, filesub)
    error('bad');
end
fprintf('Checked values\n');

% Merge subset
times = year(meta.time)>1800 & year(meta.time)<1900;
coords = [1 9 6 15];
[T, Tmeta] = merge.load( ["coord", "time"], {coords, times});
fprintf('Merged subset\n');

% Check values
siz = size(fileT);
filesub = reshape(fileT, [siz(1)*siz(2), siz(3)]);
filesub = filesub(coords, times);
if ~isequaln(T, filesub)
    error('bad');
end
fprintf('Checked values\n');

%% Rewrite metadata

% Catch incorrect size
try
    grid.rewriteMetadata( 'run', (1:4)' );
catch
    fprintf('Caught incorrect rows\n');
end

% Rewrite
newval = 3;
grid.rewriteMetadata('run', newval);
meta = grid.metadata;
if ~isequal(meta.run, newval)
    error('bad');
end
fprintf('Rewrote metadata\n');

%% Remove
% (Checked implicitly during the "add" error checks)

%% Expand

% Catch undefined dimension
try
    grid.expand('var', 'blarn');
catch
    fprintf('Caught undefined dimension.\n');
end

% Catch incorrect columns
try
    grid.expand('run', [3 5]);
catch
    fprintf('Caught incorrect columns\n');
end

% Expand
expvals = [4;5];
grid.expand('run', expvals);
fprintf('Expanded grid\n');

% Check metadata
meta = grid.metadata;
if ~isequal(meta.run, [newval; expvals])
    error('bad');
end
fprintf('Checked metadata\n');

% Check size
if ~isequal(grid.size(6), 3)
    error('bad');
end
fprintf('Checked size\n');

%% Rename sources

[path, name, ext] = fileparts(full);
newfile = strcat(path,'\rename\', name, ext);
movefile(full, newfile);

% Catch incorrect new file
try
    grid.renameSources(newfile, f2);
catch
    fprintf('Caught incorrect rename\n');
end

% Rename
grid.renameSources;
fprintf('Renamed sources\n');

% Check file path
if ~strcmp(newfile, grid.source.file(1,:))
    error('bad');
end
fprintf('Checked file name\n');

movefile(newfile, full);