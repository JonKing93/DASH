function[path] = sourceFilepath(obj, path, useAbsolute)
%% gridfile.sourceFilepath  Convert data source absolute path to requested path style
% ----------
% path = <strong>obj.sourceFilepath</strong>(path, absolute)
% Converts a data source file path to the path style requested for a .grid
% file. Path style can either be absolute or relative to the .grid file.
% Also implements URL file separators.
% ----------
%   Inputs:
%       path (string scalar): The absolute path to a data source
%       useAbsolute (scalar logical): Whether to return an absolute path
%           (true) or a relative path (false)
%
%   Outputs:
%       path (string scalar): The data source file path in the requested
%           style with URL file separators.
%
% <a href="matlab:dash.doc('gridfile.updateMetadataField')">Documentation Page</a>

if ~useAbsolute
    path = dash.file.relativePath( path, fileparts(obj.file) );
end
path = dash.file.unixStylePath(path);

end