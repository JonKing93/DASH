function[path, isrelative] = relativePath(toFile, fromFolder)
%% dash.file.relativePath  Determine the relative path to a file from a folder
% ----------
%   [path, isrelative] = dash.file.relativePath(toFile, fromFolder)
%   Attempts to determine the relative path to a file from a folder. If the
%   file and folder are located on separate drives, uses the absolute file
%   path. Returns the path to the file and indicates whether the path is a
%   relative or absolute path.
% ----------
%   Inputs:
%       toFile (string scalar): The absolute path to a file
%       fromFolder (string scalar): The absolute path to a folder
%
%   Outputs:
%       path (string): The relative path to the file, or the absolute path
%           if the file and folder are on different drives. If a relative
%           path, begins with ./
%       isrelative (scalar logical): True if path is a relative path. False
%           if the path is an absolute path.
%
% <a href="matlab:dash.doc('dash.file.relativePath')">Documentation Page</a>

% Get the folders along each path
fileseps = {'/','\'};
to = strsplit(toFile, fileseps);
from = strsplit(fromFolder, fileseps);

% Find the last common folder
n = min(numel(to), numel(from));
match = strcmp(to(1:n), from(1:n));
branch = find(~match, 1, 'first') - 1;
if isempty(branch)
    branch = n;
end

% If no common folders, use the absolute path
if branch==0
    path = toFile;
    isrelative = false;
    
% Otherwise build relative path
else
    nUp = numel(from) - branch;
    toBranch = repmat({'..'}, [1 nUp]);
    folders = [{'.'}, toBranch, to(branch+1:end)];
    path = strjoin(folders, '/');
    isrelative = true;
end

end