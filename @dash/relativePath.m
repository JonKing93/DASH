function[path] = relativePath(toFile, fromFolder)
% Returns the relative path to a file on the current machine.
%
% path = dash.relativePath(toFile)
% Returns the relative path to a file from the current working directory.
% If the file is on a different drive, returns the absolute path.
%
% path = dash.relativePath(toFile, fromFolder)
% Returns the relative path to a file from a specified starting folder.
%
% ----- Inputs -----
%
% toFile: The absolute path to a file on the current machine. A string.
%
% fromFolder: The absolute path to the starting folder on the current machine.
%    A string.
%
% ----- Outputs -----
%
% path: The relative path to the file.

% Get the folders along each path
to = split(toFile, filesep);
from = split(fromFolder, filesep);

% Find the last common folder on the paths
n = min( numel(to), numel(from) );
match = strcmp( to(1:n), from(1:n) );
branch = find(~match, 1, 'first') - 1;
if isempty(branch)
    branch = n;
end

% If there are no common folders, use the absolute path to the file
if branch == 0
    path = toFile;
    
% Otherwise, build the relative path
else
    nUp = numel(from) - branch;
    toBranch = repmat({'..'}, [1 nUp]);
    path = fullfile('.', toBranch{:}, to{branch+1:end});
end

end