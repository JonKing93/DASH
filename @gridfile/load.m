function[X, meta] = load(obj, dimensions, indices)
%% gridfile.load  Load data from the sources catalogued in a gridfile.
% ----------
%   [X, meta] = <strong>obj.load</strong>
%   Loads all the data catalogued in a gridfile. Returns the loaded data
%   array and grid metadata for the array.
%
%   [X, meta] = <strong>obj.load</strong>(dimensions)
%   Returns the loaded data in a custom dimension order. The order of
%   dimensions in the loaded array will match the order specified in the
%   dimensions list. If the gridfile has dimension that are not specified
%   in the dimension order, the unspecified dimensions are moved to the end
%   of the order.
%
%   [X, meta] = <strong>obj.load</strong>(dimensions, indices)
%   Specify which elements to load along each dimension. The order of
%   elements in the returned array will match the order of specified
%   indices. Returned metadata will only hold metadata for the specified
%   indices, and the rows of the metadata will match the order of the
%   indices. If indices are not specified for a dimension, the method loads
%   all data elements along that dimension.
% ----------
%   Inputs:
%       dimensions (string vector [nDims]): The requested order of
%           dimensions in the loaded data. Each element must be the name of
%           a dimension in the gridfile. Dimension names cannot be
%           repeated.
%       indices (cell vector [nDims] {empty array | logical vector [dimension length] | vector, linear indices}):
%           The indices of data elements to load. A cell vector with a
%           set of indices for each dimension listed in the dimension order.
%           Each set of indices must either be a logical vector the length
%           of the dimension, a set of linear indices, or an empty array.
%           If the indices for a dimension are an empty array, all elements
%           along the dimension are loaded.
%
%           If only a single dimension is listed in the dimension order,
%           the dimension's indices may be provided directly, instead of in
%           a scalar cell. However, the cell syntax is still permitted.
%
%           Note: Any dimensions not listed in the dimension order will be
%           loaded in full.
%
%   Outputs:
%       X: The loaded data. If specified, dimensions are in the requested
%           order. Will only include specified elements along each
%           dimension if dimension indices are provided.
%       meta (gridMetadata object): Metadata for the loaded array. The
%           metadata for each dimension will only include values for loaded
%           data elements.
%
% <a href="matlab:dash.doc('gridfile.load')">Documentation Page</a>

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