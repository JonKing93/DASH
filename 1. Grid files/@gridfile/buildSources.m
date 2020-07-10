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

filenames = obj.collectPrimitives("file", s);
sources = obj.buildSourcesForFiles(s, filenames);

end