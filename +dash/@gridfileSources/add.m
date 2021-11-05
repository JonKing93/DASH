function[obj] = add(obj, grid, dataSource, dims, size, mergedDims, mergedSize)

% Relative or absolute path to data source. Use URL separators
sourceName = dataSource.source;
isrelative = false;
if grid.relativePath
    gridPath = fileparts(grid.file);
    [sourceName, isrelative] = dash.file.relativePath(sourceName, gridPath);
end
sourceName = dash.file.urlSeparators(sourceName);
obj.source = [obj.source; sourceName];
obj.relativePath = [obj.relativePath; isrelative];

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

obj.dims = [obj.dims; dims];
obj.size = [obj.size; size];
obj.mergedDims = [obj.mergedDims; mergedDims];
obj.mergedSize = [obj.mergedSize; mergedSize];

% Data transformations
obj.fill = [obj.fill; grid.fill];
obj.range = [obj.range; grid.range];
obj.transform = [obj.transform; grid.transform_];
obj.transform_params = [obj.transform_params; grid.transform_params];

end