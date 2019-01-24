% This is a quickstart demo for DASH.
%
% Before running this quickstart, you will need to place the files:
% 
% surface.b.e11.BLMTRC5CN.f19_g16.003.cam.h0.T.085001-184912.nc    AND
% surface.b.e11.BLMTRC5CN.f19_g16.003.cam.h0.T.185001-200512.nc
%
% on your active path. They are available on the Earth System grid (ESG) by
% UCAR / NCAR.

%% Create gridfile

% Get data
fprintf('Loading data from .nc file: ');
files = {'surface.b.e11.BLMTRC5CN.f19_g16.003.cam.h0.T.085001-184912.nc';
         'surface.b.e11.BLMTRC5CN.f19_g16.003.cam.h0.T.185001-200512.nc';} ;
T = cat(4, ncread(files{1},'T'), ncread(files{2},'T') );
gridDims = {'lon','lat','lev','time'};
fprintf('Finished. \n');

% Get metadata
lat = ncread(files{1}, 'lat');
lon = ncread(files{1}, 'lon');
time = cat(1, daynoleap2datenum(ncread(files{1}, 'time'), 850, 'dt' )-calmonths(1)+caldays(14), ...
              daynoleap2datenum(ncread(files{2}, 'time'),1850, 'dt' )-calmonths(1)+caldays(14) );
run = 3;
lev = 1;

% Create a metadata structure for dash
meta = buildMetadata(T, gridDims, 'T', 'lat', lat, 'lon', lon, 'time', time, 'run', run, 'lev', lev);

% Create the gridfile
file = 'T.mat';

fprintf('Building .mat file: ');
newGridfile('T.mat', T, gridDims, meta );
fprintf('Finished. \n');

clearvars T


%% Design a state vector

fprintf('Designing state vector: ');

% Get some indices
latNH = meta.lat>0;
june = month(time)==6;
altLon = 1:2:numel(meta.lon); % Use alternate longitudes for a smaller state vector.

% Create a state vector design and add a variable
d = stateDesign('test');
d = addVariable(d, 'T.mat', 'T');

% Edit the design
d = editDesign(d, 'T', 'run', 'ens');
d = editDesign(d, 'T', 'lat', 'state', 'index', latNH);
d = editDesign(d, 'T', 'lon', 'state', 'index', altLon);
d = editDesign(d, 'T', 'time', 'ens', 'index', june, 'seq', [0 1 2], 'meta', {'June','July','August'});

fprintf('Finished.\n\n');

% Look at the design
dispDesign(d);
input('Please examine the design. Press enter to continue: ');

%% Build an ensemble

fprintf('Building Ensemble: ');
nEns = 100;
[M, ensMeta] = buildEnsemble( d, 15 );
fprintf('Finished.\n');

%% Get Observations

fprintf('Making Observations: ');

% Get some obs. We'll do 3 UK 37 obs and 2 temperature sensitive trees
nYears = 15;
ukObs = randInterval( .1, .8, [3, nYears]);
treeObs = randInterval( -3, 3, [2, nYears]);
D = [ukObs; treeObs];

% Get their coordinates
nObs = size(D,1);
obCoord = [randInterval(1,89,[nObs,1]), randInterval(1,359,[nObs,1])];

% Get their uncertainty
R = repmat( 0.1 * std(D,[],2), [1, nYears] );

fprintf('Finished.\n');

%% PSMs

fprintf('Building PSMs: ');

% Preallocate PSMs and sample indices
F = cell(nObs,1);
H = cell(nObs,1);

% For each observation, make a PSM and get the sample indices.
for k = 1:nObs
    
    % First 3 obs are UK 37
    if k < 4
        newPSM = ukPSM( obCoord(k,:), 'convertT', -273.15 );
        H{k} = newPSM.getStateIndices( ensMeta, 'T', 'time', 'June' );
        
    % Second 2 obs are temperature sensitive trees
    else
        newPSM = vstempPSM( obCoord(k,:), 2, 20, 'intwindow', [6 7 8], 'convertT', -273.15 );
        H{k} = newPSM.getStateIndices( ensMeta, 'T', {'June','July','August'} );
    end
    
    % Add to PSM array
    F{k} = newPSM;
end

fprintf('Finished.\n');

%% Data Assimilation

fprintf('Performing DA: ');

% Inflation factor
inflate = 2;

% Covariance localization
stateCoord = cell2mat([ensMeta.lat, ensMeta.lon]);
w = covLocalization( obCoord, stateCoord, 10000 );

% Run the DA
[A, Ye] = dash( M, D, R, w, inflate, 'full', H, F );

fprintf('Finished.\n');


%% Summary
%
% Number of lines of dash code by section
%
%   Gridfile: 2
%       meta = buildMetadata( ... )
%       newGridfile( ... )
%
%   Design: 6
%       d = stateDesign(...)
%       d = addVariable(...)
%       d = editDesign( ... )   x 4
%
%   Ensemble: 1
%       [M, ensMeta] = buildEnsemble;
%
%   Observations: 0
%
%   PSM: 4
%       ukPSM(...)
%       ukPSM.getStateIndices(...)
%       vstempPSM(...)
%       vstempPSM.getStateIndices(...)
%
%   DA: 2
%       covLocalization(...)
%       dash(...)
%
% Total lines of user code from .nc file to finished analysis: 15
%                                   Excluding design and PSMs: 5