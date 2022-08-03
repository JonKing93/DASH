function[path] = collapsePath(path)
%% dash.file.collapsePath  Collapse . and .. entries in a file path
% ----------
%   path = dash.file.collapsePath(path)
%   Removes . entries from a file path. Also removes .. entries and
%   associated subfolders. Returns the final file path using url-style file
%   separators (/).
% ----------
%   Inputs:
%       path (string scalar): A file path containing . and/or .. entries.
%
%   Outputs:
%       path (string scalar): The file path without . or .. entries.
%
% <a href="matlab:dash.doc('dash.file.collapsePath')">Documentation Page</a>

path = strsplit(path, {'/','\'});
path(strcmp(path, '.')) = [];

moveUp = find(strcmp(path, '..'), 1);
while ~isempty(moveUp)
    path([moveUp-1, moveUp]) = [];
    moveUp = find(strcmp(path, '..'), 1);
end

path = strjoin(path, '/');

end