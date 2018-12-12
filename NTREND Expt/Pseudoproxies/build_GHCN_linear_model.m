function[linReg, gPseudo] = build_GHCN_linear_model( ghcn )

%%%%%%% User specified

% The calibration interval
calLim = [1950 1990];

% Fraction of NaN in the calibration interval that disqualify a station
% from consideration.
nanfrac = 0.33;

%%%%%%%%


% Load the GHCN data
if nargin == 1
    gmeta = loadGHCN;
else
    [gmeta, ghcn] = loadGHCN;
end
gDate = gmeta.date;
gmeta = gmeta.ghcnMeta;

% Load the NTREND data
[crn, sYear, season, sLon, sLat] = loadNTREND;
crn(:,13) = crn(:,12); % Replace the site that regresses poorly

% Restrict both datasets to 1950 - 1990
gDex = (year(gDate) >= calLim(1)) & (year(gDate) <= calLim(2));
ghcn = ghcn(gDex,:);

sDex = (sYear >= calLim(1)) & (sYear <= calLim(2));
crn = crn(sDex,:);

% Remove Southern Hemisphere from GHCN
SHdex = gmeta.lat < 0;

gmeta(SHdex,:) = [];
ghcn(:, SHdex) = [];

% Find sites that contain more NaN values than allowed
nVals = size(ghcn,1);
nNan = sum( isnan(ghcn) );
nandex = (nNan / nVals) > nanfrac;

% Remove sites with too many NaN
ghcn(:,nandex) = [];
gmeta(nandex,:) = [];

% Map each NTREND site to the closest station 
H = samplingMatrix( [sLat, sLon], [gmeta.lat, gmeta.lon], 'linear');
ghcn = ghcn(:,H);

% Preallocate the JJA mean
nYear = nVals / 12;
nSite = size( crn,2);
Tseas = NaN( nYear, nSite);

% Get the annual seasonal mean
for s = 1:nSite
    for y = 1:nYear
        Tseas(y,s) = mean( ghcn( (y-1)*12 + season{s}, s) );
    end
end

% Preallocate the linear regression and GHCN pseduoproxies
linReg = NaN( nSite, 3);
gPseudo = NaN( nYear, nSite);

% For each site
for s = 1:nSite
    
    % Get the predictor and response variables
    predictor = [ones(nYear,1), Tseas(:, s)];
    response = crn(:,s);
    
    % Get the index of non-NaN elements
    dex = ~isnan(Tseas(:,s)) & ~isnan( crn(:,s) );
    
    % Do the linear regression. Also record N for each regression
    linReg(s,1:2) = predictor(dex,:) \ response(dex);
    linReg(s,3) = sum(dex);    
    
    % Create a pseudo proxy from the linear regression on the GHCN data.
    % Also record the GHCN data.
    gPseudo(:,s) = linReg(s,1) + ( linReg(s,2) * Tseas(:,s) );
end

% Add temperature data to the gPseduo record
gPseudo = {gPseudo, Tseas};

end