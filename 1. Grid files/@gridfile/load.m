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
%    dimension. Indices may be either linear indices or a logical vector
%    the length of the dimension. Must be in the same order as the
%    dimension names listed in dims.
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
        dash.assertNumericVectorN( input{i}, nInputDims, name(i) );
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
    for d = 1:nInputDims
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

% Preallocate indices for all dimensions, the size of the output grid, and
% the dimension limits of the requested values, and the output metadata
nDims = numel(obj.dims);
indices = cell(nDims, 1);
outputSize = NaN(1, nDims);
loadLimit = NaN(nDims, 2); 
meta = obj.meta;

% Get indices for all .grid dimensions
indices(inputOrder) = inputIndices;
for d = 1:nDims
    if isempty(indices{d})
        indices{d} = 1:obj.size(d);
    end
    
    % Determine the size of the dimension, and dimensions limits
    outputSize(d) = numel(indices{d});
    loadLimit(d,:) = [min(indices{d}), max(indices{d})];
    
    % Limit the metadata to these indices
    meta.(obj.dims(d)) = meta.(obj.dims(d))(indices{d},:);
end

% Preallocate the output
X = NaN( outputSize );

% Check each data source to see if it contains any requested data
tooLow = any(all(loadLimit < obj.dimLimit, 2), 1);
tooHigh = any(all(loadLimit > obj.dimLimit, 2), 1);
useSource = find(~tooLow & ~tooHigh);

% Build a data source object for each source with required data
[type, file, var, unmergedDims] = obj.collectPrimitives(["type","file","var","unmergedDims"], useSource);
for s = 1:numel(useSource)
    unmerged = gridfile.commaDelimitedToString( unmergedDims(s) );
    source = dataSource.new( type(s), file(s), var(s), unmerged );
    
    % Preallocate the location of requested data relative to the source
    % grid, and relative to the output grid
    nMerged = numel(source.mergedDims);
    sourceIndices = cell(1, nMerged);
    outputIndices = repmat({':'}, [1,nDims]);
    
    % Get the .grid dimension indices covered by the data source
    for d = 1:nDims
        limit = obj.dimLimit(d,:,useSource(s));
        dimIndices = limit(1):limit(2);
        
        % Get the indices of the requested data relative to the source grid
        % and the output grid
        [ismem, sourceDim] = ismember(obj.dims(d), source.mergedDims);
        if ismem
            [~, loc] = ismember( indices{d}, dimIndices );
            sourceIndices{sourceDim} = loc(loc~=0);
            outputIndices{d} = ismember( dimIndices(sourceIndices{sourceDim}), indices{d} );
        else
            outputIndices{d} = dimIndices;
        end
    end
    
    % Load the data from the data source
    Xsource = source.read( sourceIndices );
    
    % Permute to match the order of the .grid dimensions. Add to output
    dimOrder = 1:nDims;
    [~, gridOrder] = ismember( source.mergedDims, obj.dims );
    gridOrder(end+1:nDims) = dimOrder(~ismember(dimOrder, gridOrder));
    X(outputIndices{:}) = permute(Xsource, gridOrder);
end

% Permute to match the user's specified dimension order
dimOrder = 1:nDims;
inputOrder = [dimOrder(inputOrder), dimOrder(~ismember(dimOrder,inputOrder))];
X = permute(X, inputOrder);
meta = orderfields(meta, inputOrder);
dims = obj.dims(inputOrder);

% Remove any undefined singleton dimensions from the data and the metadata
isdefined = obj.isdefined(inputOrder);
order = [find(isdefined), find(~isdefined)];
X = permute(X, order);
meta = rmfield( meta, dims(~isdefined) );
    
end