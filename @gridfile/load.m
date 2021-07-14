function[X, meta] = load(obj, dims, indices, count, stride)
%% Reads values from the data sources managed by a .grid file.
%
% [X, meta] = obj.load
% Returns the entire data grid managed by the .grid file and metadata for
% each dimension of the returned data grid. The order of the metadata
% fields is the dimension order of the output data grid.
%
% [X, meta] = obj.load( dims )
% Returns the data grid in the specified dimension order.
%
% [X, meta] = obj.load( dims, indices )
% Only returns data at requested indices for specified dimensions. Loads
% all elements of remaining dimensions.
%
% [X, meta] = obj.load(dims, start, count)
% Specifies the number of elements to load from the specified dimensions.
% Default is to load all elements.
%
% [X, meta] = obj.load(dims, start, count, stride)
% Specifies the inter-element spacing to use when loading data from the
% specified dimensions. Default is a spacing of 1.
%
% ----- Inputs -----
%
% dims: A list of dimension names for which additional load arguments are
%    being specified. A string vector or cellstring vector. Any dimensions
%    not listed in dims will have all elements loaded.
%
% indices: A cell vector. Must have the same number of elements as dims. 
%    Each element contains the indices at which to load data for one
%    dimension. Must be in the same order as the dimension names listed in
%    dims. Indices may be linear indices, a logical vector the length of
%    the dimension, or an empty array. If an empty array, loads all
%    elements along the dimension.
%
% start: A vector whose elements indicate the starting element at which to 
%    begin loading data from a specified dimension. Must have one element
%    for each dimension listed in dims and be in the same order as dims. If
%    start = [], defaults to the first element in each dimension.
%
% count: A vector whose elements indicate the number of elements to read 
%    from specified dimensions. Must have one element for each dimension
%    listed in dims and be in the same order as dims. Use Inf to read until
%    the end of a dimension. If count = [], defaults to Inf for all
%    dimensions.
%
% stride: A vector whose elements indicate the inter-element spacing to use
%    when loading data from specified dimensions. Must have one element for
%    each dimension listed in dims and be in the same order as dims. If
%    stride = [], defaults to an inter-element spacing of 1.
%
% ----- Outputs -----
%
% X: The loaded data grid.
%
% meta: The dimensional metadata for the loaded data grid and any
%    non-dimensional data attributes.

% ***Note: This method is mostly an error checker for user inputs. Most of
% the actual work is done by the "repeatedLoad" method.

% Update the object in case the file changed
obj.update;

% Default and error check dimensions
if ~exist('dims','var')
    inputOrder = [];
else
    dims = dash.assert.strlist(dims, "dims");
    obj.checkAllowedDims(dims, false);
    if numel(dims) < numel(unique(dims))
        error('dims contains duplicate names');
    end
    
    % Count input dimensions and map to internal grid dimensions
    nInputDims = numel(dims);
    [~, inputOrder] = ismember(dims, obj.dims);
end

% Default indices
if ~exist('indices','var')
    indices = [];
    
% If indices are provided directly, parse and error check the cell vector
elseif exist('indices','var') && ~exist('count','var')
    [indices, wasCell] = dash.parse.inputOrCell(indices, nInputDims, "indices");
    name = 'indices';
    
    % Error check indices for individual dimensions
    for d = 1:nInputDims
        if wasCell
            name = sprintf('Element %.f of indices', d);
        end
        lengthName = sprintf('the length of the %s dimension', obj.dims(inputOrder(d)));
        indices{d} = dash.assert.indices(indices{d}, name, obj.size(inputOrder(d)), lengthName );
    end
    
% Otherwise use start/count/stride syntax. Get defaults
else
    start = indices;
    if isempty(start)
        start = ones(1, nInputDims);
    end
    if isempty(count)
        count = Inf(1, nInputDims);
    end
    if ~exist('stride','var') || isempty(stride)
        stride = ones(1, nInputDims);
    end
    
    % Error check start, count, stride inputs
    scs = {start, count, stride};
    name = ["start","count","stride"];
    allowInf = [false, true, false];
    for i = 1:3
        dash.assert.vectorTypeN( scs{i}, 'numeric', nInputDims, name(i) );
        dash.assert.positiveIntegers( scs{i}, name(i), false, allowInf(i) );
        if any( scs{i}>obj.size(inputOrder) & ~isinf(scs{i}) )
            bad = find(scs{i}>obj.size(inputOrder),1);
            error('Element %.f of %s (%.f) is larger than the length of the %s dimension (%.f)', bad, name(i), start(bad), obj.dims(inputOrder(bad)), obj.size(inputOrder(bad)) );
        end
    end
    
    % Get the count for Inf elements
    k = isinf(count);
    count(k) = ceil(  (obj.size(inputOrder(k))-start(k)+1) / stride(k)  );
    
    % Get the indices. Check they don't exceed the dimension length
    indices = cell(1, nInputDims);
    for d = 1:nInputDims
        stop = start(d) + stride(d)*(count(d)-1);
        if stop > obj.size(inputOrder(d))
            error('The start, count, and stride for dimension %s specify values up to %.f, which is larger than the length of the dimension (%.f)', ...
                obj.dims(inputOrder(d)), stop, obj.size(inputOrder(d)) );
        end
        indices{d} = start(d):stride(d):stop;
    end
end

% Load the values
[X, meta] = obj.repeatedLoad(inputOrder, indices);

end