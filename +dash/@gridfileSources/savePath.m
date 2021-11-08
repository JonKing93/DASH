function[obj] = savePath(obj, dataSource, tryRelative, s)

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