function[path] = sourceFilepath(obj, path, absolute)
%% Converts an absolute path for a data source to the path stored by the .grid file
%
% path = obj.sourceFilepath(path, absolute)
% Converts a data source file path to the path style requested for a .grid
% file. Implements UNIX style file separators.
%
% ----- Inputs -----
%
% path: A filepath. A string.
%
% absolute: A scalar logical. Whether to use an absolute path (true) or not.
%
% ----- Outputs -----
%
% path: The file path for the .grid file.

if ~absolute
    path = dash.file.relativePath( path, fileparts(obj.file) );
end
path = dash.file.unixStylePath(path);

end