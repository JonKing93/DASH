function[Tmeta, T] = loadLMESurfaceT( stateDex, runDex, timeDex)
%% Loads the state vectors of LME Surface temperature data for specified 
% locations, LME runs, and time indices. Supports partial loading to limit
% memory constraints.
%
% [Tmeta, T] = loadLMESurfaceT( stateDex, runDex, timeDex )
% 
% ----- Inputs -----
%
% stateDex: A logical array indicating the state vector locations to be
%      loaded. Leave empty to use all state vector locations.
%
% runDex: A logical array indicating the LME runs to be loaded. Leave empty
%      to load all runs.
%
% timeDex: A logical array indicating the time points to be loaded. Leave
%      empty to load all time points.
%
% ----- Outputs -----
%
% Tmeta: Metadata on the Surface T output. Includes run number, date, lat,
%      and lon.
%
% T: The output 

% Load the metadata
Tmeta = load('LME_Tsurface_Full_metadata.mat');

% Get defaults if unspecified
if ~exist(timeDex,'var') || isempty(timeDex)
    timeDex = true( numel(Tmeta.date),1);
end
if ~exist(runDex,'var') || isempty(runDex)
    runDex = true( numel(Tmeta.run), 1);
end
if ~exist(stateDex,'var') || isempty(stateDex)
    stateDex = true( numel(Tmeta.lat), 1);
end

% Load the T data
if nargout > 1
    m = matfile('LME_Tsurface_Full.mat');
    T = m.T(stateDex, runDex, timeDex);
    
    % Adjust the metadata
    Tmeta.lat = Tmeta.lat(stateDex);
    Tmeta.lon = Tmeta.lon(stateDex);
    Tmeta.date = Tmeta.date(timeDex);
    Tmeta.run = Tmeta.run(runDex);
end

end