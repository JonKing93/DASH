function[T, time, lon, lat] = loadSampleStack
%% Loads the sample LME control run.
%
% [T, time] = loadSampleStack

s = load('sampleTStack.mat');

T = s.T;
time = s.time;
lon = s.lon;
lat = s.lat;

end