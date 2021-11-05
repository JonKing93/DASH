function[dataSource] = build(obj, s, filepath)
%% dash.gridfileSources.build
% ----------
%   obj.build(s)
%   Builds a data source object for the specified data source stored in the
%   gridfileSources object.
%
%   obj.build(s, filepath)
%   Builds a data source object using values stored in the gridfileSources
%   object, but with a custom filepath.
% ----------

% Default file path
if ~exist('filepath','var')
    filepath = obj.absolutePaths(s);
end

% Mat source
if strcmp(obj.type(s), 'mat')
    dataSource = dash.dataSource.mat(filepath, obj.var(s));
    
% NC source
elseif strcmp(obj.type(s), 'nc')
    dataSource = dash.dataSource.nc(filepath, obj.var(s));
    
% Text
elseif strcmp(obj.type(s), 'text')
    [hasoptions, k] = ismember(s, obj.importOptionSource);
    options = {};
    if hasoptions
        options = obj.importOptions{k};
    end
    dataSource = dash.dataSource.text(filepath, options{:});
end

end