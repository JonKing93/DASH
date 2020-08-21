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

% Get the saved file names for the requested sources
filenames = obj.collectPrimitives("file", s);

% Convert relative paths to absolute
gridFolders = split(obj.file, filesep);
for f = 1:numel(filenames)
    file = char(filenames(f));
    if file(1)=='.'
        fileFolders = split(file,'/');
        filenames(f) = fullfile(gridFolders{:}, fileFolders{:});
    end
end

% Build data sources
sources = obj.buildSourcesForFiles(s, filenames);

end