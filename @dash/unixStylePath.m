function[path] = unixStylePath(path)
% Converts a file path string for the current machine to a path using UNIX 
% style file separators.
%
% path = dash.unixStylePath(path);
%
% ----- Inputs -----
%
% path: A path string that uses the file conventions of the current machine
%
% ----- Outputs -----
%
% path: A path string using Unix style file separators.

folders = split(path, filesep)';
folders = [folders; repmat({'/'}, [1 numel(folders)])];
path = strcat(folders{:});
path(end) = [];

end