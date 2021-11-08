function[tf, property, sourceValue, gridValue] = ismatch(obj, dataSource, s)
%% dash.gridfileSources.ismatch  Test error if a data source object is compatible with recorded values

% Initialize
tf = false;

% Compare type
property = 'type';
sourceValue = dataSource.dataType;
gridValue = obj.dataType(s);
if ~strcmp(sourceValue, gridValue)
    return;
end

% Compare sizes. Remove trailing singleton dimensions
property = 'size';
gridValue = strsplit(obj.size(s), ',');
gridValue = str2double(gridValue);
gridValue = formatSize(gridValue);
sourceValue = formatSize(dataSource.size);
if ~isequal(sourceValue, gridValue)
    return;
end

% Passed the tests
tf = true;
property = '';
sourceValue = [];
gridValue = [];

end
function[siz] = formatSize(siz)
lastDim = find(siz>1, 1, 'last');
siz = siz(1:lastDim);
if isempty(siz)
    siz = [1 1];
elseif isscalar(siz)
    siz = [siz, 1];
end
siz = sprintf('%.fx', siz);
siz(end) = [];
end