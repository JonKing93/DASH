% Part 1: Prepare all the data

% Load the NTREND Data
[crn, siteYear, lonSite, latSite] = loadNTREND;

% Convert longitude to 0 - 360.
lonSite(lonSite<0) = 360 + lonSite(lonSite<0);

% Also load the model ensemble. (CESM-LME full forcing runs 2-13)
[T, lonM, latM, timeM] = loadTdoff;

% Restrict time indices to 850-2000
treeDex = (siteYear>=850 & siteYear<=2000);
crn = crn(treeDex,:);
siteYear = siteYear(treeDex);

ensDex = ( timeM>=datetime(850,1,1) & timeM<=datetime(2001,1,0) );
T = T(:,:,ensDex);
timeM = timeM(ensDex);