% Load the NTREND data
[~,~,season, lon, lat] = loadNTREND;

% Load the temperature and moisture thresholds
TP = load('TPthreshold.mat');
T1 = TP.T1;
T2 = TP.T2;
M1 = TP.M1;
M2 = TP.M2;

% Load the temperature climatologies
Tclim = load('Tclim.mat');
Tclim = Tclim.Tclim;

% Remove bad sites
del = [52;2;20];
season(del) = [];
lon(del) = [];
lat(del) = [];
T1(del) = [];
T2(del) = [];
M1(del) = [];
M2(del) = [];

% Get metadata needed to determine state indices
Tname = 'T';
Pname = 'P';
timeMeta = {'Jan','Feb','March','April','May','June','July','Aug','Sep','Oct','Nov','Dec'};

% Preallocate cell array to hold PSM instances
F = cell( numel(lat), 1 );

% For each site
for s = 1:numel(F)
    
    % Create an instance of the PSM. (The constructor)
    F{s} = vslitePSM( [lat(s), lon(s)], T1(s), T2(s), M1(s), M2(s), Tclim(:,s),...
        'intwindow', season{s}, 'convertT', -273.15, 'convertP', 2.592E9 );
    
    % Get the state indices for the site
    F{s}.getStateIndices( ensMeta, Tname, Pname, timeMeta(season{s}) );
    
    % Get the standardization values
    F{s}.setStandardization( M );
end


