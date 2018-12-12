function[linModel, lmeProxy] = build_LME_Pseudos(linReg, gPseudo, T)
%% Builds the "true" pseudo-proxies from LME run 2 after tuning the linear model.
%
% [linModel, lPseudo] = build_LME_Pseudos(linReg, gPseudo)
% 

%%%%% User Specified
season = [6 7 8];
%%%%%

% Load the T data
Tmeta = loadLMESurfaceT;

% If not provided, load T from run 2
if nargin<3
    runDex = find(Tmeta.run == 2);
    [Tmeta, T] = loadLMESurfaceT( [], runDex );
end
    
% Load NTREND
[crn, sYear, ~, sLon, sLat] = loadNTREND;

% Get the indices of LME grids closest to NTREND sites
H = samplingMatrix( [sLat, sLon], [Tmeta.lat, Tmeta.lon], 'linear' );

% Restrict the LME data to the spatial sites. Convert to 2D matrix.
T = squeeze( T(H,:,:) )';

% Further restrict LME data to JJA
seasonDex = ismember( month(Tmeta.date), season );
T = T(seasonDex,:);

% Preallocate the seasonal mean of T
nMonth = numel(season);
nYear = size(T,1) / nMonth;
nSite = size(T,2);
Tseas = NaN(nYear, nSite);

% Get the seasonal mean
for t = 1:nYear
    Tseas(t,:) = mean(  T( (t-1)*nMonth+1:t*nMonth, :)  );
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

end
% 

