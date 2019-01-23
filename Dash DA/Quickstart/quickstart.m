%% Create gridfile

% Get data
files = {'surface.b.e11.BLMTRC5CN.f19_g16.003.cam.h0.T.085001-184912.nc';
         'surface.b.e11.BLMTRC5CN.f19_g16.003.cam.h0.T.185001-200512.nc';} ;
     
T = cat(4, ncread(files{1},'T'), ncread(files{2},'T') );
gridDims = {'lon','lat','lev','time'};

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
newGridfile('T.mat', T, gridDims, meta );
clearvars T

%% Design a state vector

% Get some indices
latNH = meta.lat>0;
june = month(time)==6;

% Build a design and add a variable
d = stateDesign('test');
d = addVariable(d, 'Ttest.mat', 'T');

% Edit the design properties
% Broke everything during rewrite, edit the design by hand
% % d = editDesign(d, 'T', 'run', 'ens');
% % d = editDesign(d, 'T', 'lat', latNH );
% % d = editDesign(d, 'T', 'time', 'ens', june, 'mean', [0 1 2], 'meta', 'JJA' );
d.var.indices{3} = 49:96;
d.var.indices{5} = 1:12:13000;
d.var.seqDex{5} = [0,1,2];
d.var.ensMeta{5} = {'June','July','August'};
d.var.isState = [true false, true true false];

%% Build an ensemble

nEns = 15;
[M, ensMeta] = buildEnsemble( d, 15 );

%% Get Observations

% Get some obs. We'll do 3 UK 37 obs and 2 temperature sensitive trees
nYears = 15;
ukObs = randInterval( .1, .8, [3, nYears]);
treeObs = randInterval( -3, 3, [2, nYears]);
D = [ukObs; treeObs];

% Get their uncertainty
R = 0.1 * std(D,[],2);

% Get their coordinates
nObs = size(D,1);
obCoord = [randInterval(1,89,[nObs,1]), randInterval(1,359,[nObs,1])];

%% PSMs

% Preallocate PSMs and sample indices
F = [];
H = cell(nObs,1);

% For each observation, make a PSM and get the sample indices.
for d = 1:nObs
    
    % First 3 obs are UK 37
    if d < 4
        newPSM = ukPSM( obCoord(d,:), 'convertT', -273.15 );
        H{d} = newPSM.getStateIndices( ensMeta, 'T', 'time', 'June' );
        
    % Second 2 obs are temperature sensitive trees
    else
        newPSM = vstempPSM( obCoord(d,:), 2, 20, 'intwindow', [6 7 8], 'convertT', -273.15 );
        H{d} = newPSM.getStateIndices( ensMeta, 'T', {'June','July','August'} );
    end
end

%% Data Assimilation

% Inflation factor
inflate = 2;

% Covariance localization
w = covLocalization( obCoord, [ensMeta.lat, ensMeta.lon], 10000 );

% Run the DA
[A, Ye] = dash( M, D, R, w, inflate, 'full', H, F );


%% Summary
%
% Number of lines of dash code by section
%
%   Gridfile: 2
%       meta = buildMetadata( ... )
%       newGridfile( ... )
%
%   Design: 5
%       d = stateDesign(...)
%       d = addVariable(...)
%       d = editDesign( ... )   x 3
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
% Total lines of user code from .nc file to finished analysis: 14
%                                   Excluding design and PSMs: 5