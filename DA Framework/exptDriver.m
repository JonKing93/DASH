% This is the driver for my test of DA framework using the NTREND data.

% Begin by loading the ntrend data
[crn, year, lonSite, latSite] = loadNTREND;

% Convert longitude to 0 - 360.
lonSite(lonSite<0) = 360 + lonSite(lonSite<0);

% Also load the model stack
[T, timeT, lonM, latM] = loadSampleStack;

% Restrict to July 850-2000
treeDex = (year>=850 & year<=2000);
ensDex = ( timeT>=datetime(850,1,1) & timeT<=datetime(2001,1,0) & month(timeT)==7 );

crn = crn(treeDex,:);
T = T(:,:,ensDex);

year = year(treeDex);
timeT = timeT(ensDex);

% Convert to state vector ensembles. N x MC for the models, p x time for
% the obs
crn = crn';

[nLon, nLat, nTime] = size(T);
T = reshape(T, nLon*nLat, nTime);

% Get the edges of the model gridcells
lonSpace = lonM(2)-lonM(1);
latSpace = latM(2)-latM(1);

lonEdge = [lonM-0.5*lonSpace; lonM(end)+0.5*lonSpace];
latEdge = [latM-0.5*latSpace; latM(end)+0.5*latSpace];

% Remove overlapping observations at 12 and 13
crn(12,:) = [];
lonSite(12) = [];
latSite(12) = [];

% Get the sampling matrix, H, for the observations
modelGridEdges = {lonEdge, latEdge};
siteCoords = [lonSite, latSite];

H = buildH( modelGridEdges, siteCoords);

% Use a scaled standard deviation of each tree chronology as a crude estimate of
% observational error-variance
R = 0.05 * nanstd(crn,0,2);

nTime = size(crn,2);
R = repmat(R, 1, nTime);

% Create an output file
fname = 'NTREND_DA_output.nc';
delete(fname);
nccreate( fname, 'T', ...
    'Dimensions', {'lon',length(lonM), 'lat',length(latM), 'time',nTime}, ...
    'FillValue', NaN);

writeArgs = {fname, 'T', [length(lonM), length(latM)]};

% Run the data assimilation
ensrfDriver( T, crn, R, H, writeArgs );










