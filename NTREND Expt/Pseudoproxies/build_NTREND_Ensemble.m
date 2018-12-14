function[M, Tmeta] = build_NTREND_Ensemble( nEns, season )
%% Builds the static ensemble for the NTREND experiment.
%
% M = build_NTREND_Ensemble( nEns, season )
%
% ----- Inputs -----
%
% nEns: The size of the ensemble
%
% season: The months over which to take the seasonal mean. E.g. [6 7 8]
%      for JJA
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

nState = numel(Tmeta.lat);

% Preallocate the ensemble
M = NaN(nState, nEns);

% Get the number of runs that are not the truth run. Also get the number of
% years.
nRun = numel(Tmeta.run) - 1;
nYears= numel(Tmeta.date) / 12;

% Get the number of draws to do from each run. Select as evenly as possible
% from runs 3 - 11.
nDraw = floor( nEns / nRun ) * ones(nRun,1);

oneMore = 1:mod(nEns,nRun);
nDraw(oneMore) = nDraw(oneMore) + 1;
nDraw = [0; nDraw];   % So indexing matches the run metadata

% For each run that is not the truth run
mdex = 1;
for rdex = 2:nRun+1
    
    % Load the temperature variable from the run
    [~, T] = loadLMESurfaceT( [], rdex, 1:1200 );
    
    % Restrict to the Northern Hemisphere
    T = squeeze( T(NHdex,:,:) );
    
    % Draw random years.
    timeDex = randsample( 1:nYears, nDraw(rdex) );
    
    % For each year...
    for y = 1:numel(timeDex)
        
        % Record the mean in the season of interest
        M(:, mdex) = mean( T(:, (y-1)*12 + season), 2 );
        mdex = mdex + 1;
    end
end

% Remove time and run from metadata output. Adjust the 2D size
Tmeta = rmfield(Tmeta, 'run');
Tmeta = rmfield(Tmeta, 'date');
Tmeta.iSize = Tmeta.iSize ./ [1 2];
        
end