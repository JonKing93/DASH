function[X, meta] = load(obj, dimensions, indices)

% Setup
obj.update;
header = "DASH:gridfile:load";

% Default is all dimensions
if ~exist('dimensions','var') || isempty(dimensions)
    outputOrder = [];
    
% Otherwise, error check dimensions
else
    dims = dash.assert.strlist(dimensions, 'dimensions');
    dimsName = sprintf('dimension in gridfile "%s"', obj.name);
    [~, outputOrder] = dash.assert.strsInList(dims, obj.dims, 'dimensions', dimsName, header);
    nDims = numel(dims);
    
    % No duplicate names
    if nDims < numel(unique(outputOrder))
        duplicateDimensionError(obj, outputOrder, header);
    end
end

% Default indices is an empty array
if ~exist('indices','var') || isempty(indices)
    indices = cell(nDims, 1);
    
% Otherwise, error check indices cell
else
    name = 'indices';
    [indices, wasCell] = dash.parse.inputOrCell(indices, nDims, name, header);
    
    % Then check indices for each dimension
    for k = 1:nDims
        d = outputOrder(k);
        dim = obj.dims(d);
        if wasCell
            name = sprintf('Element %.f of indices', k);
        end
        lengthName = sprintf('the length of the "%s" dimension', dim);
        indices{k} = dash.assert.indices(indices{k}, obj.dims(d), ...
            name, lengthName, [], header);
    end
end

% Load the values
[X, meta] = obj.repeatedLoad(outputOrder, indices);

end

% Error message
function[] = duplicateDimensionError(obj, outputOrder, header)
inputDims = 1:numel(outputOrder);
[~, iUnique] = unique(outputOrder);
repeated = find(~ismember(inputDims, iUnique), 1);
repeated = obj.dims(outputOrder(repeated));

id = sprintf('%s:repeatedDimension', header);
error(id, 'Dimension name "%s" is provided multiple times', repeated);
end