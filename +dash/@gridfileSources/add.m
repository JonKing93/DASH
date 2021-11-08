function[obj] = add(obj, grid, dataSource, dims, size, mergedDims, mergedSize, mergeMap)

% Data source file type and saved data type
if isa(dataSource, 'dash.dataSource.mat')
    type = "mat";
elseif isa(dataSource, 'dash.dataSource.nc')
    type = "nc";
elseif isa(dataSource, 'dash.dataSource.text')
    type = "text";
end
obj.type = [obj.type; type];
obj.dataType = [obj.dataType; dataSource.dataType];

% Save relative or absolute path to data source
obj = obj.savePath(dataSource, grid.relativePath);

% HDF variable names
varName = "";
if isa(dataSource, 'dash.dataSource.hdf')
    varName = dataSource.var;
end
obj.var = [obj.var; varName];

% Import options are stored in a cell, which can severely slow
% down gridfile saves. Use source indexing to only record
% import options when necessary.
if isa(dataSource, 'dash.dataSource.text') && ~isempty(dataSource.importOptions)
    obj.importOptions = [obj.importOptions; dataSource.importOptions];
    obj.importOptionSource = [obj.importOptionSource; numel(obj.source)];
end            

% Gridfile dimensions
dims = strjoin(dims, ',');
size = strjoin(string(size), ',');
mergedDims = strjoin(mergedDims, ',');
mergedSize = strjoin(string(mergedSize), ',');
mergeMap = strjoin(string(mergeMap), ',');

obj.dims = [obj.dims; dims];
obj.size = [obj.size; size];
obj.mergedDims = [obj.mergedDims; mergedDims];
obj.mergedSize = [obj.mergedSize; mergedSize];
obj.mergeMap = [obj.mergeMap; mergeMap];

% Data transformations
obj.fill = [obj.fill; grid.fill];
obj.range = [obj.range; grid.range];
obj.transform = [obj.transform; grid.transform_];
obj.transform_params = [obj.transform_params; grid.transform_params];

end