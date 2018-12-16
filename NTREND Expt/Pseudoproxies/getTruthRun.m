function[Tmeta, Ttrue] = getTruthRun( timeDex, season )

% Load run 2 in the years of interest
[Tmeta, T] = loadLMESurfaceT( [], 2, timeDex );

% Restrict to the Northern Hemisphere
NHdex = Tmeta.lat > 0;

T = squeeze( T(NHdex,:,:) );
Tmeta.lat = Tmeta.lat(NHdex);
Tmeta.lon = Tmeta.lon(NHdex);
Tmeta.iSize = Tmeta.iSize ./ [1 2];

% Preallocate the seasonal mean and time metadata
nYear = numel(timeDex)/12;
nState = size(T,1);
Ttrue = NaN( nState, nYear);
date = repmat( datetime(0,0,0), nYear, numel(season) );

% Get the seasonal mean
for t = 1:nYear
    Ttrue(:,t) = mean( T(:,(t-1)*12 + season), 2);
    date(t,:) = Tmeta.date( (t-1)*12+season );
end
Tmeta.date = date;

end