function[paths] = collectFullPaths(obj, s)
%% Returns the full absolute filepaths for specified data sources.
%
% paths = obj.collectFullPaths(s)
% Converts paths for data source files to absolute paths. Relative paths
% have the .grid file path appended to the front. Paths that are already
% absolute are left unaltered.
%
% ----- Inputs -----
%
% s: The linear indices of the data sources in the .grid file for which to
%    obtain file paths
%
% ----- Outputs -----
%
% paths: A string vector of absolute file paths.

% Get the file names
paths = obj.collectPrimitives("source", s);

% Get the .grid file folders
gridPath = fileparts(obj.file);
gridFolders = split(gridPath, filesep);

% Append the .grid file path to relative paths
for f = 1:numel(paths)
    file = char(paths(f));
    if file(1)=='.'
        fileFolders = split(file,'/');
        paths(f) = fullfile(gridFolders{:}, fileFolders{:});
    end
end

end