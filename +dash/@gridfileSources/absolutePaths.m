function[paths] = absolutePaths(obj, s)
%% dash.gridfileSources.absolutePaths  Return the absolute paths to data sources in the catalogue
% ----------
%   paths = <strong>obj.absolutePaths</strong>
%   Returns the absolute paths to all data sources. Paths are returned in
%   the order that sources are stored in the object.
%
%   paths = <strong>obj.absolutePaths</strong>(s)
%   Returns the absolute paths to the specified data sources. Paths are
%   returned in the order of input indices.
% ----------
%   Inputs:
%       s (logical vector [nSources] | vector, linear indices): The indices
%           of the data sources for which to return absolute paths.
%
%   Outputs:
%       paths (string vector): The absolute paths to the data sources
%
% <a href="matlab:dash.doc('dash.gridfileSources.absolutePaths')">Documentation Page</a>

% Default is all sources
if ~exist('s','var') || isempty(s)
    s = 1:numel(obj.source);
end

% Get source paths, check if any are relative
paths = obj.source(s);
rel = obj.relativePath(s);

% If relative, append grid path and collapse
if any(rel)
    gridPath = fileparts(obj.gridfile);
    absPaths = strcat(gridPath, '/', paths(rel));
    for p = 1:numel(absPaths)
        absPaths(p) = dash.file.collapsePath(absPaths(p));
    end
    paths(rel) = absPaths;
end

end