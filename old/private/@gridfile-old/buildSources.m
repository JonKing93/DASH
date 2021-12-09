function[sources] = buildSources(obj, s)
%% Builds dataSource objects from values stored in a .grid file.
%
% sources = obj.buildSources(s)
%
% ----- Inputs -----
%
% s: The linear indices of the data sources in the .grid file to build
%
% ----- Outputs -----
%
% sources: A cell array of dataSource objects

% Get the file paths for the requested sources
filenames = obj.collectFullPaths(s);

% Build data sources
sources = obj.buildSourcesForFiles(s, filenames);

end