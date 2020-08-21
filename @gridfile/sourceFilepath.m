function[path] = sourceFilepath(obj, path, relative)
%% Converts an absolute path for a data source to the path stored by the .grid file
%
% path = obj.sourceFilepath(path, relative)
% Optionally converts a data source file path to a path relative to the
% .grid file. Implements UNIX style file separators.
%
% ----- Inputs -----
%
% path: A filepath. A string.
%
% relative: A scalar logical.
%
% ----- Outputs -----
%
% path: The file path stored in the .grid file.

if relative
    path = dash.relativePath( path, obj.file );
end
path = dash.unixStylePath(path);

end