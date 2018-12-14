function[linModel, lmeProxy] = build_LME_Pseudos(linReg, gPseudo, season)
%% Builds the "true" pseudo-proxies from LME run 2 after tuning the linear model.
%
% [linModel, lPseudo] = build_LME_Pseudos(linReg, gPseudo)
% 

% Load the T data
Tmeta = loadLMESurfaceT;

% If not provided, load T from run 2
runDex = find(Tmeta.run == 2);
[Tmeta, T] = loadLMESurfaceT( [], runDex, 1:1200 );
    
% Remove the Southern hemisphere
NHdex = Tmeta.lat>0;
T = squeeze( T(NHdex,:,:) );
Tmeta.lat = Tmeta.lat(NHdex);
Tmeta.lon = Tmeta.lon(NHdex);    
    
% Load NTREND
[crn, sYear, ~, sLon, sLat] = loadNTREND;

% Get the indices of LME grids closest to NTREND sites
H = samplingMatrix( [sLat, sLon], [Tmeta.lat, Tmeta.lon], 'linear' );

% Restrict the LME data to the spatial sites. Convert to 2D matrix.
T = squeeze( T(H,:,:) )';

% Preallocate the seasonal mean
nYear = size(T,1) / 12;
nSite = size(T,2);
Tseas = NaN( nYear, nSite);

% Get the seasonal mean
for t = 1:nYear
    Tseas(t,:) = mean( T((t-1)*12+season, :), 1 );
end

% Tune the linear regression intercept to account for model bias
% between the NTREND and LME data.
gMean = nanmean(gPseudo{2})';
tMean = nanmean(Tseas)';

newIntercept = linReg(:,1) + (linReg(:,2) .* gMean) - (linReg(:,2) .* tMean);

% This gives the final linear model
linModel = [newIntercept, linReg(:,2)];

% Now, preallocate the pseudo proxies
lmeProxy = NaN( size(Tseas) );

% Construct pseudoproxies from the LME data
for s = 1:nSite
    lmeProxy(:,s) = linModel(s,1) + (linModel(s,2) .* Tseas(:,s));
end

% Add temperature seasonal mean data for future reference
lmeProxy = {lmeProxy, Tseas};

% Do a second build using the linearPSM class
linPSM = linearPSM( linModel(:,2), linModel(:,1) );

end
% 

