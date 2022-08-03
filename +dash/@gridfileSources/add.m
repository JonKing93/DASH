function[obj] = add(obj, grid, dataSource, dims, size, mergedDims, mergedSize, mergeMap)
%% dash.gridfileSources.add  Add a new data source to the catalogue
% ----------
%   obj = <strong>obj.add</strong>(grid, dataSource, dims, size, mergedDims, mergedSize, mergedMap)
%   Adds a new data source to a gridfile catalogue. Converts the data type
%   of various properties to speed up save/load operations.
% ----------
%   Inputs:
%       grid (scalar gridfile object): The parent gridfile object
%       dataSource (scalar dataSource object): The dataSource object for
%           the new source file.
%       dims (string vector [nNonTS]): The names of non-trailing-singleton
%           dimensions in the data source.
%       size (numeric vector [nNonTS]): The size of each
%           non-trailing-singleton dimension in the source.
%       mergedDims (string vector [nMerged]): The names of the merged
%           non-ts dimensions in the data source.
%       mergedSize (numeric vector [nMerged]): The size of the merged
%           non-ts dimensions in the data source.
%       mergeMap (numeric vector [nNonTS]): Each element maps an original
%           dimension to a merged dimension for the source. Has one element
%           per original dimension. Each element holds the index of the
%           merged dimension that includes the original dimension.
%
%   Outputs:
%       obj (scalar dash.gridfileSources object): The updated catalogue.
%
% <a href="matlab:dash.doc('dash.gridfileSources.add')">Documentation Page</a>

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
    obj.importOptions = [obj.importOptions; {dataSource.importOptions}];
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