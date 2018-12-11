function[Tmeta, T] = loadLMESurfaceT( stateDex, runDex, timeDex)
%% Loads the state vectors of LME Surface temperature data for specified 
% locations, LME runs, and time indices. Supports partial loading to limit
% memory constraints, which requires consistent incrementing for each index
% array.
%
% [Tmeta, T] = loadLMESurfaceT( stateDex, runDex, timeDex )
% 
% ----- Inputs -----
%
% stateDex: A vector with the indices of state vector locations to be loaded.
%      Leave empty to load all locations. Must have consistent incrementing.
%
% runDex: A vector with the indices of LME runs to be loaded. Leave empty
%      to load all runs. Must have consistent incrementing.
%
% timeDex: A vector with the indices of time point ot be loaded. Leave
%      empty to load all time points. Must have consistent incrementing.
%
% ----- Outputs -----
%
% Tmeta: Metadata on the Surface T output. Includes run number, date, lat,
%      and lon.
%
% T: The output temperature.

% Load the metadata
Tmeta = load('LME_Tsurface_Full_metadata.mat');

% Get defaults if unspecified
if ~exist('timeDex','var') || isempty(timeDex)
    timeDex = 1:numel(Tmeta.date);
end
if ~exist('runDex','var') || isempty(runDex)
    runDex = 1:numel(Tmeta.run);
end
if ~exist('stateDex','var') || isempty(stateDex)
    stateDex = 1:numel(Tmeta.lat);
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