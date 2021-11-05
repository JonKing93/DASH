function[paths] = absolutePaths(obj, s)
%% Returns the absolute paths to all data sources

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