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

% Note: This function is mostly an error checker for user load requests.
% The workhorse function for actually loading data is loadInternal

% Setup
header = "DASH:gridfile:load";
dash.assert.scalarObj(obj, header);
obj.update;

% Parse and error check dimensions
if ~exist('dimensions','var') || isempty(dimensions)
    userDimOrder = [];
else
    dims = dash.assert.strlist(dimensions, 'dimensions', header);
    listName = sprintf('dimension in gridfile "%s"', obj.name);
    userDimOrder = dash.assert.strsInList(dims, obj.dims, 'Dimension name', listName, header);
    dash.assert.uniqueSet(dims, 'Dimension name', header);
end
nDims = numel(userDimOrder);

% Parse and error check indices
if ~exist('indices','var') || isempty(indices)
    indices = cell(1, nDims);
end
dimLengths = obj.size(userDimOrder);
indices = dash.assert.indexCollection(indices, nDims, dimLengths, obj.dims(userDimOrder), header);

% Get load indices and build required data sources
loadIndices = obj.getLoadIndices(userDimOrder, indices);
s = obj.sourcesForLoad(loadIndices);
[dataSources, failed, cause] = obj.buildSources(s);

% Informative error if any data sources failed
if any(failed)
    dataSourceFailedError(cause);
end

% Load the values
[X, meta] = obj.loadInternal(userDimOrder, loadIndices, s, dataSources);

end