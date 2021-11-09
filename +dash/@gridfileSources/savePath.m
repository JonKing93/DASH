function[obj] = savePath(obj, dataSource, tryRelative, s)
%% dash.gridfileSources.savePath  Record the path to a data source in the catalogue
% ----------
%   obj = obj.savePath(dataSource, tryRelative)
%   Records the path to a new data source in the catalogue.
%
%   obj = obj.savePath(dataSource, tryRelative, s)
%   Update the path to a data source in the catalogue.
% ----------
%   Inputs:
%       dataSource (string scalar | dataSource object): The data source
%           being recorded in the catalogue. If a string scalar, must be
%           the absolute filename of the data source file.
%       tryRelative (scalar logical): Set to true to attempt to save the
%           relative path to the data source. Set to false to always save
%           the absolute path.
%       s (numeric scalar): The index of a data source in the catalogue
%           whose path should be updated.
%
%   Outputs:
%       obj (gridfileSources object): The updated catalogue.
%
% <a href="matlab:dash.doc('dash.gridfileSources.savePath')">Documentation Page</a>

% Get absolute path
if isa(dataSource, 'dash.dataSource.Interface')
    sourceName = dataSource.source;
else
    sourceName = dataSource;
end
isrelative = false;

% Optionally attempt to get a relative path
if tryRelative
    gridPath = fileparts(obj.gridfile);
    [sourceName, isrelative] = dash.file.relativePath(sourceName, gridPath);
end

% Always use URL file internally
sourceName = dash.file.urlSeparators(sourceName);

% Update existing path
if exist('s','var')
    obj.source(s) = sourceName;
    obj.relativePath(s) = isrelative;
    
% Otherwise add to array
else
    obj.source = [obj.source; sourceName];
    obj.relativePath = [obj.relativePath; isrelative];
end

end