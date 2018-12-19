function[Tmeta, M] = build_NTREND_Ensemble( nEns, season, timeDex )
%% Builds the static ensemble for the NTREND experiment.
%
% M = build_NTREND_Ensemble( nEns, season, timeDex )
%
% ----- Inputs -----
%
% nEns: The size of the ensemble
%
% season: The months over which to take the seasonal mean. E.g. [6 7 8]
%      for JJA
%
% timeDex: The time indices to consider. Leave blank for all.
%
% ----- Outputs -----
%
% M: The static ensemble.

% Get the number of state variables. This should exclude all variables in
% the southern hemisphere.
Tmeta = loadLMESurfaceT;
NHdex = (Tmeta.lat>0);

Tmeta.lat = Tmeta.lat(NHdex);
Tmeta.lon = Tmeta.lon(NHdex);
Tmeta.iSize = Tmeta.iSize ./ [1 2];

nState = numel(Tmeta.lat);

% Preallocate the ensemble
M = NaN(nState, nEns);

% Get the number of runs and years.
nRun = numel(Tmeta.run);
nYears= numel(Tmeta.date) / 12;

% Get the number of draws to do from each run. Select as evenly as possible
% from runs 3 - 11. Do not draw from the truth run
nDraw = floor( nEns / (nRun-1) ) * ones(nRun-1,1);

oneMore = 1:mod(nEns,nRun-1);
nDraw(oneMore) = nDraw(oneMore) + 1;
nDraw = [0; nDraw];   % So indexing matches the run metadata

% For each run that is not the truth run
mdex = 1;   % This is the index in the ensemble, nEns_k 
for rdex = 2:nRun
    
    % Load the temperature variable from the run
    [~, T] = loadLMESurfaceT( [], rdex, timeDex );
    
    % Restrict to the Northern Hemisphere
    T = squeeze( T(NHdex,:,:) );
    
    % Draw random years.
    drawDex = randsample( 1:nYears, nDraw(rdex) );
    
    % For each year that is drawn...
    for y = 1:numel(drawDex)
        
        % Record the mean in the season of interest
        M(:, mdex) = mean( T(:, (y-1)*12 + season), 2 );
        mdex = mdex + 1;
    end
end

% Remove time and run from metadata output. Adjust the 2D size
Tmeta = rmfield(Tmeta, 'run');
Tmeta = rmfield(Tmeta, 'date');
        
end