function[dataSource] = build(obj, s, filepath)
%% dash.gridfileSources.build  Build the dataSource object for a data source in the catalogue
% ----------
%   dataSource = <strong>obj.build</strong>(s)
%   Builds a data source object for the specified data source stored in the
%   gridfileSources object.
%
%   dataSource = <strong>obj.build</strong>(s, filepath)
%   Builds a data source object using values stored in the gridfileSources
%   object, but with a custom filepath.
% ----------
%   Inputs:
%       s (numeric scalar): The index of a data source in the catalogue.
%       filepath (string scalar): The absolute filename to use when
%           building the dataSource.
%
%   Outputs:
%       dataSource (scalar dataSource object): The dataSource object for
%           the source file.
%
% <a href="matlab:dash.doc('dash.gridfileSources.build')">Documentation Page</a>

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