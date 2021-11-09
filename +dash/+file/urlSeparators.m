function[path] = urlSeparators(path)
%% dash.file.urlSeparators  Replace windows-style (\) file separators with url-style (/) separators
% ----------
%   path = dash.file.urlSeparators(path)
%   Replaces (\) file separators with (/) separators in a file path.
% ----------
%   Inputs:
%       path (string scalar): A file path to convert.
%
%   Outputs:
%       path (string scalar): A file path using URL-style file separators.
%
% <a href="matlab:dash.doc('dash.file.urlSeparators')">Documentation Page</a>

path = strsplit(path, '\');
path = strjoin(path, '/');
end