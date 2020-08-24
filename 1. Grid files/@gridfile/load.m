function[X, meta] = load(obj, dims, start, count, stride)
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
% [X, meta] = obj.load(dims, start)
% Specify the index at which to start loading data in specified dimensions.
% Default is the first index.
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
%    being specified. A string vector or cellstring vector. Only dimensions
%    with defined metadata in the .grid file are allowed. Any dimensions
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
%    listed in dims and be in the same order as dims. Use Inf to read all
%    elements from a dimension. If count = [], defaults to all elements in 
%    each dimension.
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

% Defaults for unset variables
if ~exist('dims','var') || isempty(dims)
    dims = obj.dims(obj.isdefined);
end
nInputDims = numel(dims);
if ~exist('start','var') || isempty(start)
    start = ones(1, nInputDims);
end
if ~exist('count','var') || isempty(count)
    count = Inf(1, nInputDims);
end
if ~exist('stride','var') || isempty(stride)
    stride = ones(1, nInputDims);
end

% Parse the input style: indices vs start,count,stride
haveIndices = false;
if iscell(start)
    haveIndices = true;
    inputIndices = start;
    if nargin>3
        error('There can only be two input arguments (dims and indices) when specifying indices.');
    end
end

% Error check the dimensions
dash.assertStrList(dims, "dims");
obj.checkAllowedDims(dims, true);
if numel(dims) < numel(unique(dims))
    error('dims contains duplicate names.');
end

% Map dims to the internal grid dimensions
[~, inputOrder] = ismember(dims, obj.dims);

% If indices were not specified, generate them from start, count, stride
if ~haveIndices
    inputIndices = cell(1, nInputDims);

    % Error check inputs
    input = {start, count, stride};
    name = ["start","count","stride"];
    allowInf = [false true false];

    for i = 1:numel(input)
        dash.assertVectorTypeN( input{i}, 'numeric', nInputDims, name(i) );
        dash.assertPositiveIntegers( input{i}, false, allowInf(i), name(i) );
        if any( input{i}>obj.size(inputOrder) & ~isinf(input{i}) )
            bad = find(input{i}>obj.size(inputOrder),1);
            error('Element %.f of %s (%.f) is larger than the length of the %s dimension (%.f)', bad, name(i), start(bad), obj.dims(inputOrder(bad)), obj.size(inputOrder(bad)) );
        end
    end

    % Get the indices. Check they don't exceed the length of the dimension.
    count(isinf(count)) = obj.size(inputOrder(isinf(count)));
    for d = 1:nInputDims
        stop = start(d) + stride(d)*(count(d)-1);
        if stop > obj.size(inputOrder(d))
            error('The start, count, and stride for dimension %s specify values up to %.f, which is larger than the length of the dimension %.f', obj.dims(inputOrder(d)), stop, obj.size(inputOrder(d)) );
        end
        inputIndices{d} = start(d):stride(d):stop;
    end

% If the user specified the indices, error check 
else 
    if ~isvector(inputIndices) || numel(inputIndices) ~= nInputDims
        error('indices must be a vector with %.f elements.', nInputDims);
    end
    
    % Default for empty indices
    for d = 1:nInputDims
        if isempty(inputIndices{d})
            inputIndices{d} = 1:obj.size(inputOrder(d));
        end
        
        % Error check
        if ~isvector(inputIndices{d})
            error('Element %.f of indices must be a vector.', d);
        end
        
        % Error check logical indices. Convert to linear.
        if islogical(inputIndices{d})
            if numel(inputIndices{d})~=obj.size(inputOrder(d))
                error('Element %.f of indices is a logical vector, but it is not the length of the %s dimension (%.f)', d, obj.dims(inputOrder(d)), obj.size(inputOrder(d)) );
            end
            inputIndices{d} = find(inputIndices{d});
            
        % Error check linear indices.
        elseif isnumeric(inputIndices{d})
            dash.assertPositiveIntegers(inputIndices{d}, false, false, sprintf('Element %.f of indices',d));
            if max(inputIndices{d})>obj.size(inputOrder(d))
                error('Element %.f of indices specifies values up to %.f, which is larger than the length of the %s dimension (%.f)', find(inputIndices{d}==max(inputIndices{d},1)), max(inputIndices{d}), obj.dims(inputOrder(d)), obj.size(inputOrder(d)) );
            end
            
        % Other types are not allowed
        else
            error('Element %.f of indices must be a logical or numeric vector.', d);
        end
    end
end

% Load the values. The "load" method doesn't actually make repeated load
% operations, so will use a placeholder dataSource array.
[X, meta] = obj.repeatedLoad(inputOrder, inputIndices);

end