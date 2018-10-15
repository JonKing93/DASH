function[Tdoff, lon, lat, time] = loadTdoff()
%% Loads the Dynamic offline ensemble of CESM-LME surface temperature.
% [Tdoff, lon, lat, time] = loadTdoff
load('Tdoff.mat');
end